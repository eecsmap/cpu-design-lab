#!/usr/bin/env python3
"""Emit a black-box stub for a firtool-generated module.

Vivado errors out on missing submodules rather than inferring black boxes, so
isolating one module for synthesis needs stubs with matching port lists.
Reads the real .sv, copies the module header verbatim, emits an empty body
marked (* black_box *).

    make_blackbox.py <real.sv> <ModuleName> > stub.sv
"""
import re, sys

src, name = sys.argv[1], sys.argv[2]
text = open(src).read()

m = re.search(r'^module\s+%s\s*\((.*?)^\);' % re.escape(name), text, re.S | re.M)
if not m:
    sys.exit("could not find module %s in %s" % (name, src))

ports = m.group(1)
# strip firtool's source-location comments; they carry no port information
ports = re.sub(r'//.*', '', ports)
ports = "\n".join(l.rstrip() for l in ports.splitlines() if l.strip())

print("// Auto-generated black-box stub -- do not edit.")
print("(* black_box *)")
print("module %s(" % name)
print(ports)
print(");")
print("endmodule")
