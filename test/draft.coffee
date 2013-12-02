l = console
#jade = require 'jade'
#
#jade_string = [
#    ':markdown',
#    '    ## This is markdown!',
#    '    * First',
#    '    * #{var2}',
#    '    * Third'
#].join('\n');
#
#l.log (jade.compile jade_string, { pretty: true }) var1: "First!", var2: "Second!"

              ## Why use *modules* like **AMD** or **Common/JS** ?
l.log require('marked') """
              * Write *modular, maintainable & reusable code*, with clearly stated dependencies.

              * The damnation of authoring Javascript as **one huge file** or **concatenating** must end!
              ```coffee
              // this is code
              coffeescript = do(indeed = 'great!')-> alert indeed
              ```
"""