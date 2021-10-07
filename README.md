# **WARNING - This is a public repo used to host a custom action for GitHub workflows. Do not include proprietary or sensitive data.**

# actions-workflow-info
Provide information about the named workflow.

## Inputs

### `name`

**Required** The name of the workflow of interest.

### `branch`

**Required** The name of the branch for the workflow runs, use "*" for all branches

### `repository`

**Required** The name of the repository (owner/repo).

### `token`

**Required** The GitHub API access token.

## Outputs

### `last-build-run-number`

The run number of the last build of the selected workflow runs.
This includes completed runs.

### `last-build-sha`

The commit SHA of the last build of the selected workflow runs.

### `running-workflows-count`

The number of selected workflow runs that are running.
This includes completed runs.

### `running-jobs-count`

The number of jobs that are running (status != completed) on the selected
workflow runs, filtered by job-name. 0 if job-name not specified.

### `workflow-id`

The numeric id of the named workflow.

## Example usage

```yaml
uses: onshape/actions-workflow-info@v1
with:
  name: ${{ env.WORKFLOW_NAME }}
  branch: ${{ matrix.branch }}
  repository: ${{ github.repository }}
  token: ${{ secrets.GITHUB_TOKEN }}
```

To test:

You can put these lines like these in a script to easily test your changes. Put
the GitHub PAT in a file named `.pat`. Do not commit either file.

```shell
docker build -t actions-workflow-info .
docker run --rm actions-workflow-info "--job-name" "build-and-publish" "--name" "build-test-deploy" "--branch" "master" "--repository" "onshape/newton" "--token" $(cat .pat)
```
