# Create passwords from the extracted base names 
print("Making each gopro wifi dictionary file\n\tThis may take a minute")
max = 10000
slist = ['snow', 'wind', 'dude', 'wave', 'skate', 'share', 'climb', 'stoke', 'travel', 'action', 'family', 'bike', 'surf', 'sail', 'dive', 'hike', 'tennis', 'sport', 'cycle', 'kayak', 'canoe', 'scuba', 'swim', 'sled', 'jump', 'soccer', 'racer', 'vault', 'epic']

f = open("gopro_dict.txt", "w")
f.writelines("#Built by Hypoxic for the GoPro HERO[5,6,7,2018]\n")

#add the default pw for older cameras
f.writelines("goprohero\n")
for s in slist:
	for i in range(0, max):
		o = "%s%04d\n" % (s, i)
		f.writelines(o)
		 
f.close()