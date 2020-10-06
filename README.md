# GrepPDFsFromBing
Grep PDF files from Bing.com

GrepPDFsFromBing.ps1 v1.0 
7 october 2020 by E-D-H

Simply download PDF files from Bing.com using a search string (google seems to block that quikly)

Tested with Elvis Presley as a search string and it gave 597 .pdf files

Feel free to modify/copy/improve/whatever, Whitesmiths haters certainly do :-)

Notes:
- use at own risk, if Bing blocks you
- download function doesn't check http response codes, if not good file will be zero
- Bing behaves strange at the end and the the ">" value is not reliable, so the loop will terminate when the results are stable for 4 pages.
