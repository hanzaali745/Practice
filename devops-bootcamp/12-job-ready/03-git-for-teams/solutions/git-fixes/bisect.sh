# bisect — reference solution (run in DIR/work)
git bisect start main v1.0                        # bad, then good
git bisect run ../test_total.sh                   # git tests the middle commit, halves the range, repeats (~5 steps for 30)
git rev-parse refs/bisect/bad > ../answer.txt     # "<sha> is the first bad commit"
git show --stat refs/bisect/bad | head -5
git bisect reset                                  # back to where you were
