#!env python
sn = open('namesSys.txt', 'r')
dn = open('namesDoc.txt', 'r')
sysNames = set(sn.readlines())
docNames = set(dn.readlines())

shared = []
docOnly = []
sysOnly = []

def mkstring(list):
	return "".join(list)

for name in sysNames:
	if name in docNames:
		shared.append(name)
	else:
		sysOnly.append(name)

for name in docNames:
	if name not in sysNames:
		docOnly.append(name)		

shared.sort()
docOnly.sort()
sysOnly.sort()

sn = open('sharedNames.txt', 'w')
sn.write(mkstring(shared))
sn.close

don = open('docOnlyNames.txt', 'w')
don.write(mkstring(docOnly))
don.close

son = open('sysOnlyNames.txt', 'w')
son.write(mkstring(sysOnly))
son.close

print 'Shared:   ', len(shared)
print 'Doc Only: ', len(docOnly)
print 'Sys Only: ', len(sysOnly)
