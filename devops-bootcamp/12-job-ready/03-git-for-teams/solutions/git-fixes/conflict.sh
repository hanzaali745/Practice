# conflict — reference solution (run in DIR/work)
git fetch origin                                  # get Ada's new commit
git rebase origin/main || true                    # replays your commit on top — and stops on the conflict
git status --short                                # UU config.yaml
cat > config.yaml <<'EOF'
service: demo-app
replicas: 4
port: 8080
log_level: info
timeout: 30
EOF
git add config.yaml                               # "resolved"
GIT_EDITOR=true git rebase --continue             # keep the commit message
git log --oneline --graph -3                      # linear: your commit on top of Ada's
git push -u origin feature/raise-replicas
