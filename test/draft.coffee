l = console
jade = require 'jade'

jade_string = [
    ':markdown',
    '    ## This is markdown!',
    '    * First',
    '    * #{var2}',
    '    * Third'
].join('\n');

l.log (jade.compile jade_string, { pretty: true }) var1: "First!", var2: "Second!"

