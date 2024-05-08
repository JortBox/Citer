

import time, os, sys
import urllib
import urllib.request as libreq


try:
    import feedparser
except:
    os.system("pip install feedparser")
    import feedparser

import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-id', help='ArXiv ID')
args = parser.parse_args()

#prompt = f'http://export.arxiv.org/api/query?search_query={search}&start={start}&max_results={max_result}&sortBy={sortBy}'
id_prompt = f'http://export.arxiv.org/api/query?id_list={args.id}'
id_prompt = f'https://api.semanticscholar.org/graph/v1/paper/{args.id}/references?fields=title,year,authors,publicationDate,externalIds'
    
with libreq.urlopen(id_prompt) as url:
    response = url.read()
    print(response)
    
feed = feedparser.parse(response)
info_file = '/Users/jortboxelaar/Documents/citationManager/citationManager/Scripts/paper.txt'

for entry in feed.entries:
    title = entry.title
    datePublised = entry.published
    try:
        authors = [author.name for author in entry.authors]
    except:
        authors = [""]
        
    abstract = entry.summary
    
    website = ""
    pdfURL = ""
    for link in entry.links:
        if link.rel == 'alternate':
            website = link.href
        elif link.title == 'pdf':
            pdfURL =  link.href
    
    if os.path.exists(info_file):
        os.system('rm ' + info_file)  
        
    with open(info_file, 'a') as file:
        file.write(f'title: {title} \n')
        file.write(f'publicationDate: {datePublised} \n')
        file.write(f'abstract: {abstract} \n')
        file.write(f'website: {website} \n')
        file.write(f'pdfURL: {pdfURL} \n')
        file.write('authors: ')
        for author in authors:
            file.write(f'{author}, ')
        file.write('\n')
            

