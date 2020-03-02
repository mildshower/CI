# CI
### by Runtime Terror

* This app runs `npm test` and decides whether the build is failing or not

## DEPLOYMENT

1. Run `git clone https://github.com/mildshower/CI.git && cd CI`
1. To set github auth token, run `echo <yourGithubToken> > tokens/githubToken`
1. It also supports hooks.
  1. `buildFail` hook. This hook script is run when build is failing. to set this token, go inside hooks directory and add shellscript file naming `buildFail.sh` and give it executable permission.
