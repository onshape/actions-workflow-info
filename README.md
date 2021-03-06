# **WARNING - This is a public repo used to host a custom action for GitHub workflows. Do not include proprietary or sensitive data.**

# actions-workflow-info
Provide information about the named workflow.

## Inputs

### `name`

**Required** The name of the workflow of interest.

### `branch`

**Required** The name of the branch for the workflow runs.

### `repository`

**Required** The name of the repository (owner/repo).

### `token`

**Required** The GitHub API access token.

## Outputs

### `last-build-sha`

The git commit SHA of the last workflow run on the specified branch.

### `running-jobs-count`

The number running workflows for the specfied workflow and branch.

### `workflow-id`

The number id of the named workflow.

## Example usage

```yaml
uses: onshape/actions-workflow-info@v1
with:
  name: ${{ env.WORKFLOW_NAME }}
  branch: ${{ matrix.branch }}
  repository: ${{ github.repository }}
  token: ${{ secrets.GITHUB_TOKEN }}
```
