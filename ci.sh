#! /bin/zsh

prepareRepo() {
rm -rf repo
mkdir repo
cd repo
echo "\nCloning ${1}/${2} ..."
git clone git@github.com:${1}/${2}.git &> /dev/null
echo "Cloning Completed"
cd $2
echo "Installing Dependencies..."
npm install &> /dev/null
echo "Dependencies Installed"
cd ../..
}

makeArtifactPage(){
  payload=`curl -s -H "Authorization: token $(cat tokens/githubToken)" https://api.github.com/repos/${1}/${2}/commits/master`
  committer=`echo ${payload} | grep -E '^      "name"' | tail -1 | cut -d\" -f4`
  time=`echo ${payload} | grep -E '^      "date"' | tail -1 | cut -d\" -f4`
  cMessage=`echo ${payload} | grep -E '^    "message"' | cut -d\" -f4`
  page=`cat template/template.html`
  page=${page//__message__/${3}}
  page=${page/__committer__/${committer}}
  page=${page/__time__/${time}}
  page=${page/__cMessage__/${cMessage}}
  echo $page
}

updateArtifact() {
echo "\nUpdating Artifact.."
cd repo/${2}
npm test &> ../../output/info.txt

if [[ $? != 0 ]]; then 
  result=failed
  say "Build Broken"
else
  result=passed
fi

cd ../..
echo `makeArtifactPage ${1} ${2} ${result}` > output/artifact.html
echo "Artifact updated"
}

isAnyChange() {
echo "\nChecking for update at" `date`
cd repo/${2}
existingSha=`git log | head -n 1 | cut -d ' ' -f 2`
currentSha=`curl -s -H "Authorization: token $(cat ../../tokens/githubToken)" https://api.github.com/repos/${1}/${2}/commits/master | grep -E '^  "sha"' | cut -d '"' -f4`
cd ../..

[[ $existingSha != $currentSha ]]
}

main() {
  echo "Give User/Org Name:"
  read user
  echo "Give repo Name:"
  read repoName

  prepareRepo $user $repoName
  updateArtifact $user $repoName

  open output/artifact.html

  while true; do
    if isAnyChange $user $repoName; then
      prepareRepo $user $repoName
      updateArtifact $user $repoName;
    fi
    sleep 20
  done
}

main