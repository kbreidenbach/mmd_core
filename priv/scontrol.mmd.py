import sys

mmd_major="4"

def ext_order(exts):
    exts.remove(sys.modules[__name__])
    exts.insert(0,sys.modules[__name__])

def after_optparse(opts):
    if not opts.appname:
        opts.appname = "mmd_core"

    if not opts.node:
        opts.node = opts.appname+"_"+opts.env

    if not opts.cookie:
        opts.cookie = opts.node+"_"+mmd_major

            
            
            
def add_options(parser):
    parser.add_option("-t", "--tags",
                      help="add tags to this node, allows you to use services with the given tags (example: -t foo,bar,baz)",
                      dest="tags")
    parser.add_option("-f", "--force-tags",
                      help="force service tags to be applied to all service registrations (example: -f foo,bar,baz)",
                      dest="forceTags")
    
