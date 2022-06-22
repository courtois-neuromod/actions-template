# Deploy tests

This action runs tests of datalad dataset deploy

## Inputs

The action takes environment variables as inputs (`GITHUB_REPOSITORY`) and a secret access token (with write permissions to `courtois-neuromod` public repos)

## Example usage

```YAML
name: "Deploy tests"
uses: courtois-neuromod/actions-template@main
env:
  SECRET_KEY: ${{ secrets.SUPER_SECRET_SSH_KEY }}
```
