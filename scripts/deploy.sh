#!/bin/bash
#
# Mercado Static Site Deployment Script
#
# Deploys the built web application to Bulletin Chain with optional DotNS
# domain registration. This script enables third-party users to deploy their
# own instance of Mercado.
#
# Prerequisites:
#   - Node.js 18+
#   - pnpm 10.x
#   - bulletin-deploy CLI: npm install -g @parity/bulletin-deploy
#   - A Polkadot account with PAS tokens on Paseo testnet
#
# Usage:
#   ./scripts/deploy.sh [options]
#
# Options:
#   --domain <name>      Register/use a DotNS domain (e.g., myapp.dot)
#   --skip-build         Skip the build step (use existing dist/)
#   --app <name>         Which app to deploy: web (default), admin, mm-portal
#   --dry-run            Show what would be deployed without actually deploying
#   --help               Show this help message
#
# Environment Variables:
#   MNEMONIC             (required) 12/24 word mnemonic for the deployer account
#   BULLETIN_RPC         Bulletin Chain RPC endpoint
#                        Default: wss://paseo-bulletin-rpc.polkadot.io
#   ASSET_HUB_RPC        Asset Hub RPC endpoint (for token transfers)
#                        Default: wss://paseo-asset-hub-rpc.polkadot.io
#
# Examples:
#   # Deploy web app to Bulletin Chain
#   MNEMONIC="word1 word2 ..." ./scripts/deploy.sh
#
#   # Deploy with a custom DotNS domain
#   MNEMONIC="word1 word2 ..." ./scripts/deploy.sh --domain mystore.dot
#
#   # Deploy the admin panel instead
#   MNEMONIC="word1 word2 ..." ./scripts/deploy.sh --app admin
#
#   # Skip build (use existing dist folder)
#   MNEMONIC="word1 word2 ..." ./scripts/deploy.sh --skip-build
#
# Notes:
#   - This deploys to Paseo testnet by default (not mainnet)
#   - Domain registration requires additional PAS tokens for the fee
#   - The deployed site will be accessible via ipfs:// or through DotNS gateway
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Default configuration
BULLETIN_RPC="${BULLETIN_RPC:-wss://paseo-bulletin-rpc.polkadot.io}"
ASSET_HUB_RPC="${ASSET_HUB_RPC:-wss://paseo-asset-hub-rpc.polkadot.io}"
APP="web"
DOMAIN=""
SKIP_BUILD=false
DRY_RUN=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    # Extract and display the help text from the header comments
    sed -n '2,/^$/p' "$0" | sed 's/^# //' | sed 's/^#//'
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --app)
            APP="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Determine the app directory and name based on --app flag
case "$APP" in
    web)
        APP_DIR="$ROOT_DIR/apps/web"
        APP_NAME="@mercado/web"
        ;;
    admin)
        APP_DIR="$ROOT_DIR/apps/mockmobrule-admin"
        APP_NAME="@mercado/mockmobrule-admin"
        ;;
    mm-portal)
        APP_DIR="$ROOT_DIR/apps/mm-portal"
        APP_NAME="@mercado/mm-portal"
        ;;
    *)
        log_error "Unknown app: $APP"
        echo "Valid apps: web, admin, mm-portal"
        exit 1
        ;;
esac

DIST_DIR="$APP_DIR/dist"

# Validate MNEMONIC
if [[ -z "$MNEMONIC" ]]; then
    log_error "MNEMONIC environment variable is required"
    echo ""
    echo "Set the MNEMONIC environment variable with your 12 or 24 word seed phrase:"
    echo "  MNEMONIC=\"word1 word2 word3 ...\" ./scripts/deploy.sh"
    echo ""
    echo "You can get testnet PAS tokens from:"
    echo "  https://faucet.polkadot.io/?parachain=paseo"
    exit 1
fi

# Check for bulletin-deploy CLI
if ! command -v bulletin-deploy &> /dev/null; then
    log_error "bulletin-deploy CLI not found"
    echo ""
    echo "Install it with:"
    echo "  npm install -g @parity/bulletin-deploy"
    echo ""
    echo "Or use npx:"
    echo "  npx @parity/bulletin-deploy --help"
    exit 1
fi

echo ""
echo "========================================"
echo "  Mercado Bulletin Chain Deployment"
echo "========================================"
echo ""
log_info "App: $APP_NAME"
log_info "Bulletin RPC: $BULLETIN_RPC"
log_info "Asset Hub RPC: $ASSET_HUB_RPC"
if [[ -n "$DOMAIN" ]]; then
    log_info "DotNS Domain: $DOMAIN"
fi
echo ""

# Build the application
if [[ "$SKIP_BUILD" == false ]]; then
    log_info "Building $APP_NAME..."
    cd "$ROOT_DIR"

    # Install dependencies if node_modules doesn't exist
    if [[ ! -d "node_modules" ]]; then
        log_info "Installing dependencies..."
        pnpm install
    fi

    # Build the specific app and its dependencies
    pnpm --filter "$APP_NAME..." build
    log_success "Build completed"
else
    log_info "Skipping build (--skip-build flag set)"
fi

# Verify dist directory exists
if [[ ! -d "$DIST_DIR" ]]; then
    log_error "Build output not found at $DIST_DIR"
    echo "Run without --skip-build to build the application first"
    exit 1
fi

# Count files to be deployed
FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')
log_info "Found $FILE_COUNT files to deploy"

# Dry run mode
if [[ "$DRY_RUN" == true ]]; then
    log_warn "DRY RUN MODE - No actual deployment will occur"
    echo ""
    log_info "Would deploy contents of: $DIST_DIR"
    log_info "Files to deploy:"
    find "$DIST_DIR" -type f | head -20
    if [[ $FILE_COUNT -gt 20 ]]; then
        echo "  ... and $((FILE_COUNT - 20)) more files"
    fi
    echo ""
    log_info "Deployment command that would run:"
    if [[ -n "$DOMAIN" ]]; then
        echo "  bulletin-deploy upload --path \"$DIST_DIR\" --rpc \"$BULLETIN_RPC\" --domain \"$DOMAIN\""
    else
        echo "  bulletin-deploy upload --path \"$DIST_DIR\" --rpc \"$BULLETIN_RPC\""
    fi
    exit 0
fi

# Deploy to Bulletin Chain
log_info "Deploying to Bulletin Chain..."

DEPLOY_ARGS=(
    "upload"
    "--path" "$DIST_DIR"
    "--rpc" "$BULLETIN_RPC"
    "--js-merkle"
)

if [[ -n "$DOMAIN" ]]; then
    DEPLOY_ARGS+=("--domain" "$DOMAIN")
fi

# Export MNEMONIC for the CLI to use
export MNEMONIC

# Run the deployment
if bulletin-deploy "${DEPLOY_ARGS[@]}"; then
    echo ""
    log_success "Deployment completed successfully!"
    echo ""
    if [[ -n "$DOMAIN" ]]; then
        log_info "Your site is available at: https://$DOMAIN"
        log_info "Note: DNS propagation may take a few minutes"
    else
        log_info "Your site has been deployed to Bulletin Chain"
        log_info "Check the output above for the IPFS CID and access URLs"
    fi
else
    log_error "Deployment failed"
    exit 1
fi

echo ""
log_info "Next steps:"
echo "  1. Verify your deployment at the URL above"
echo "  2. Save your deployment CID for reference"
if [[ -z "$DOMAIN" ]]; then
    echo "  3. Consider registering a DotNS domain for a friendly URL:"
    echo "     ./scripts/deploy.sh --domain yourname.dot"
fi
echo ""
