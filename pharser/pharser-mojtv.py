from os import path, remove
from demjson import encode, encode_to_file
from lxml import etree
from math import floor
from time import mktime, strptime, time
import sys

FILE_PATH = 'libEPG-Mojtv.config'
CHANNELEPG_CURRENT_XML = 'guide-mojtv.xml'
lang = 'hr'

#path.exists(FILE_PATH) and remove(FILE_PATH)
jsondict = {}

currentEpgXml = CHANNELEPG_CURRENT_XML
try:
    currentEpg = etree.parse(currentEpgXml)
except:
    print("The XML is not valid: Couldn't get EPG")
    sys.exit(1)

#channel_match = 'P:'
channel_match = ''

eventid = 1
xp_title = 'title[@lang="{0}"]/text()'.format(lang)
xp_descr = 'desc[@lang="{0}"]/text()'.format(lang)

for prog in currentEpg.getiterator("programme"):
    start_time = prog.attrib["start"].split(" ", 1)[0]
    start_time = str(int(floor(mktime(strptime(start_time, "%Y%m%d%H%M%S")))))

    channel_name = channel_match + prog.attrib["channel"]
    try:
        channel = jsondict[channel_name]
    except:
        channel = []

    eventid += 1
    title = prog.xpath(xp_title)[0]
    try:
       descr = prog.xpath(xp_descr)[0]
    except:
        descr = ''

    item_dict = {}
    item_dict['title'] = title
    item_dict['description'] = descr
    item_dict['eventId'] = int(eventid)
    item_dict['time'] = int(start_time)
   
    channel.append(item_dict)

    jsondict[channel_name] = channel

encode_to_file(FILE_PATH, jsondict, overwrite=True, compactly=False)
