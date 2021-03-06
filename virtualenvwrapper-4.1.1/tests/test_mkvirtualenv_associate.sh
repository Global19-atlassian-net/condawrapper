# -*- mode: shell-script -*-

test_dir=$(cd $(dirname $0) && pwd)
source "$test_dir/setup.sh"

oneTimeSetUp() {
    rm -rf "$WORKON_HOME"
    mkdir -p "$WORKON_HOME"
    source "$test_dir/../virtualenvwrapper.sh"
}

oneTimeTearDown() {
    rm -rf "$WORKON_HOME"
    rm -f "$test_dir/requirements.txt"
}

setUp () {
    echo
    echo "#!/bin/sh" > "$WORKON_HOME/preactivate"
    echo "#!/bin/sh" > "$WORKON_HOME/postactivate"
    rm -f "$TMPDIR/catch_output"
}

test_associate() {
    project="/dev/null"
    env="env1"
    ptrfile="$WORKON_HOME/$env/.project"
    mkvirtualenv -a "$project" "$env" >/dev/null 2>&1
    assertTrue ".project not found" "[ -f $ptrfile ]"
    assertEquals "$ptrfile contains wrong content" "$project" "$(cat $ptrfile)"
}

test_preactivate() {
    project="/dev/null"
    env="env2"
    ptrfile="$WORKON_HOME/$env/.project"
	cat - >"$WORKON_HOME/preactivate" <<EOF
#!/bin/sh
if [ -f "$ptrfile" ]
then
    echo exists >> "$TMPDIR/catch_output"
else
    echo noexists >> "$TMPDIR/catch_output"
fi
EOF
    chmod +x "$WORKON_HOME/preactivate"
    mkvirtualenv -a "$project" "$env" >/dev/null 2>&1
	assertSame "preactivate did not find file" "exists" "$(cat $TMPDIR/catch_output)"
}

test_postactivate() {
    project="/dev/null"
    env="env3"
    ptrfile="$WORKON_HOME/$env/.project"
cat - >"$WORKON_HOME/postactivate" <<EOF
#!/bin/sh
if [ -f "$ptrfile" ]
then
    echo exists >> "$TMPDIR/catch_output"
else
    echo noexists >> "$TMPDIR/catch_output"
fi
EOF
    chmod +x "$WORKON_HOME/postactivate"
    mkvirtualenv -a "$project" "$env" >/dev/null 2>&1
	assertSame "postactivate did not find file" "exists" "$(cat $TMPDIR/catch_output)"
}

. "$test_dir/shunit2"
