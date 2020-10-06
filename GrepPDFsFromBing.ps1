<#
GrepPDFsFromBing.ps1 v1.0 
7 october 2020 by E-D-H

Simply download PDF files from Bing.com using a search string (google seems to block that quikly)

Tested with Elvis Presley as a search string and it gave 597 .pdf files

Feel free to modify/copy/improve/whatever, Whitesmiths haters certainly do :-)

Notes:
- use at own risk, if Bing blocks you
- download function doesn't check http response codes, if not good file will be zero
- Bing behaves strange at the end and the the ">" value is not reliable, so the loop will terminate when the results are stable for 4 pages.
#>

$uAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:81.0) Gecko/20100101 Firefox/81.0'

$curDir = $PSScriptRoot

if ($curDir -eq '' -and $null -ne $psISE) 
    {
    # Fill for ISE development
    $curDir = Split-Path -Path $psISE.CurrentFile.FullPath
    Set-Location $curDir
    }
if ($curDir -eq '' -and $null -ne $psEditor)
    {
    # Fill for VSCode development
    $curDir  = Split-Path -Path $psEditor.GetEditorContext().CurrentFile.path
    Set-Location $curDir    
    }

    function DownloadMedia($nameUrls,$outLoc)
        {
        # Downloads in this case an array of the structure nameOfTheLocalFile|urlToDownloadFrom    
        $threadMax = 4
        New-Item -ItemType Directory -Path "$outLoc\tmp" -Force

        foreach ($nu in $nameUrls)
            {
            $usplit = ($nu -split "\|")
            $n = $usplit[0]
            $u = $usplit[1]
            if (!(Test-Path $outLoc\$n))
                {
                $NetWebClient = New-Object System.Net.WebClient
                $NetWebClient.Headers.Add("user-agent",$uAgent)
                $NetWebClient.DownloadFileAsync($u,"$outLoc\tmp\$n")
                while (([System.IO.Directory]::getFiles("$outLoc\tmp",'*')).Count -ge $threadMax)
                    {
                    # The easy way
                    Start-Sleep -Milliseconds 10
                    Move-Item -Path "$outLoc\tmp\*" -Destination $outLoc -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            while (([System.IO.Directory]::getFiles("$outLoc\tmp",'*')).Count -ne 0)
                {
                Start-Sleep -Milliseconds 10
                Move-Item -Path "$outLoc\tmp\*" -Destination $outLoc -Force -ErrorAction SilentlyContinue
                }
            Start-Sleep -Milliseconds 10
            Remove-Item "$outLoc\tmp" -Force
        }

Write-Host "Give the exact search string" -ForegroundColor Yellow    
$ssTyped = read-Host 
$ss = $ssTyped.Replace(" ","+")

$outputFolder = "$curDir\greppedPDFs"

New-Item -Path $outputFolder -ItemType Directory -Force

$pdfUrls = @()
$countArr = @(0)

foreach ($i in 0..99)
    {
    $j = 1+$i*10 # strange default, perhaps can be changed with a &rpp trick
    $url = "https://www.bing.com/search?q=filetype%3apdf+`"$ss`"&first=$j"
    $iContent = Invoke-WebRequest -Uri $url -UserAgent $uAgent
    $pdfUrls += $iContent.links.href -match "^http" -match "\.pdf"
    $pdfUrls = $pdfUrls|Sort-Object -Unique
    $countArr += $pdfUrls.count
    Write-Host "Running page $i pdf counter is $($countArr[-1])" -ForegroundColor Green
    if (($countArr[-4,-3,-2,-1]|Sort-Object -Unique).count -eq 1)
        {
        Write-Host "4 pages no new PDF files, will stop the loop" -ForegroundColor Green
        break
        }
    }
if ($countArr[-1] -ne 0)
    {
    Write-Host "Downloading PDF files" -ForegroundColor Green

    # Create simple names to avoid duplicate names
    $dlArray = @()
    foreach ($c in 1..$countArr[-1])
	    {
	    $dlArray += "$ssTyped $c.pdf|$($pdfUrls[$c-1])"
	    }
    DownloadMedia $dlArray $outputFolder
    $dlArray|Out-File $outputFolder\index.txt -Encoding ascii 
    Write-Host "original name/Url can be found in the index.txt file" -ForegroundColor Green
    }
else
    {
    Write-Host "Found nothing.." -ForegroundColor Red
    }

	
