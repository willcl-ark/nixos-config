function catplain
    sed 's/\x1b\[[0-9;]*m//g' $argv
end
