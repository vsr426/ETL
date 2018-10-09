import os
import sys
import hashlib
import numpy as np

def hashfile(filename, blocksize=1024):

    hashvalue = hashlib.sha1()
    
    f= open(filename,'rb')
    while True:
        buf = f.read(blocksize)
        if not buf:
            break;
        hashvalue.update(buf)
    return hashvalue.hexdigest()

def hashOfFolder(folder):
    #Dups in the format of {HashKey:[names]}

    dups={}
    for dirName, subdirs, fileList in os.walk(folder):
        for filename in fileList:
            # Get the Full Path of the file
            filepath = os.path.join(dirName,filename)
            # Caluclate the Hash value of the file
            hashkey = hashfile(filepath)
            print("hashkey for %s is %s" %(filepath, hashkey))
            # Add or append the file 
            if hashkey not in dups:
                dups[hashkey]=['"'+filepath+'"']
            else:
                dups[hashkey].append('"'+filepath+'"')
    return dups


def joinDicts(dict1,dict2):
    for key in dict2.keys():
        if key in dict1:
            dict1[key]= dict1[key] + dict2[key]
        else:
            dict1[key]=dict2[key]


def printResults(dict1):
    """    #np.save("D:\pics\dupsFilesDict.txt",dict1)
    results = list(filter(lambda x: len(x) >1, dict1.values()))
    if len(results) >0:
        fd = os.open("D:\pics\dupsFiles.txt",os.O_RDWR|os.O_TEXT|os.O_CREAT)
        print('Duplicates Found:')
        print('The following Files are identical. The name could differ, but the content is identical')
        print('--------------------------------------------------------------------------------------')
        for result in results:
            if len(result) > 1:
                os.write(fd,'\n'.encode())
                print(result)
                for subresult in result:
                    #print('\t\t%s' %subresult)
                    os.write(fd,subresult.encode())
                    
    """
    fd = open("D:\pics\dupsFiles.txt",'wb')
    for key in dict1.keys():
        if len(dict1[key]) >1:
            fd.write('\n'.encode())
            fd.write((key+'::').encode())
            for file in dict1[key]:
                fd.write('\n\t'.encode())
                fd.write(file.encode())

    if len( list(filter(lambda x : len(x) >1,dict1.values()))) == 0:
        print('No duplicate files found')
              

if __name__ == '__main__':
    if len(sys.argv) > 1:
        dups={}
        folders = sys.argv[1:]
        for i in folders:
            #Iterate the folders given
            if os.path.exists(i):
                print("folder %s exist" %i)
                #Find the hash values of the files and append them to dups
                joinDicts(dups,hashOfFolder(i))
            else:
                print('%s is not valid path, please verify' %i)
                sys.exit()
        printResults(dups)

    else:
        print('Usage: python dupFinder.py folder or python dupFinder.py folder1 foder2 folder3')
