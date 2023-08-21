


find ${TMPDIR} -name '*clumpify*temp*' -print0 | xargs -0 -P 4 rm -f

find ${TMPDIR} -name '*clumpify*temp*' -exec rm {} \;
