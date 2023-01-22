# FUNCTIONS
function Set-Env-Vars {
    $EnvContent = Get-Content "./.env"

    foreach($Var in $EnvContent) 
    {
        $Name, $Value = $Var.split('=', 2)

        if ([string]::IsNullOrWhiteSpace($Name) -Or $Name.Contains('#')) 
        {
            continue
        }

        Set-Content env:\$Name $Value
    }
}


function Get-Title {
    param ($URL)

    $Title = . ".\yt-dlp.exe" $URL --simulate --get-title
    if($Title -eq "") 
    {
        $Title = Get-Random
    }

    return $Title
}

function Get-Output-Path {
    param ($URL)

    if($URL -like '*vimeo*') 
    {
        return 'goldmine/vimeo/%(channel)s/%(title)s.mp4'
    }

    if ($URL -like '*tiktok*') 
    {
        $Title = get-title -URL $URL
        return "goldmine/tiktok/%(uploader)s/$Title.mp4"
    } 
    
    return 'goldmine/%(channel)s/%(title)s.mp4'
}

function Get-Video {
    param($URL)

    $Path = Get-Output-Path -URL $URL
    
    . ".\yt-dlp.exe" $URL -o $Path --force-overwrites --no-warnings --concurrent-fragments 2 --user-agent 'Mozilla/5.0' --download-archive archive.txt -f bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best
    
}

#SCRIPT
Set-Env-Vars
$Sheet = Invoke-WebRequest -Uri $env:GOOGLE_SHEETS_PATH
$Source = ConvertFrom-Csv $Sheet.Content
[Array]::Reverse($Source)

foreach($Item in $Source) 
{
    if($Item.URL -like '*https://*') 
    {
        Get-Video -URL $Item.URL
    }
}
