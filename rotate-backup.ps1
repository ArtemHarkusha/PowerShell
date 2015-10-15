# Rotate folders. Folders have name convencion. It should be named by date-format(yyyy-MM-dd--HH-mm). 
# Scrip found folders and build structure where "key" = "week number", "value" = "all folders which name related to this week". Folders separates by ' '.
# For current week "key" = "currentWeek"
# Script keep one weekly folder for the past weeks and one daily folder for current week.


param(
	$backupFolder = $(throw "Backup Folder is mandatory")
)

function Get-CorrectDateFormat
{
    param(
        [String]$date = $(throw "date is mandatory parametr!!!")
    )
    [Sytem.DateTime]$correctDate = (($date -replace "--", " ").Split(' ')[0])  + " " + ((($date -replace "--", " ").Split(' ')[1]) -replace "-", ":")
    return $correctDate
}

Function GetWeekOfYear($date)
{
    # Note: first day of week is Sunday
    $intDayOfWeek = (get-date -date $date).DayOfWeek.value__
    $daysToWednesday = (3 - $intDayOfWeek)
    $wednesdayCurrentWeek = ((get-date -date $date)).AddDays($daysToWednesday)

    # %V basically gets the amount of '7 days' that have passed this year (starting at 1)
    $weekNumber = get-date -date $wednesdayCurrentWeek -uFormat %V

    return $weekNumber
}

function Do-BackupRotate
{
    param(
        $backupPath = $(throw "You must specify backups folder path!"),
        [string]$currentWeekNumber = (GetWeekOfYear(Get-Date))
    )
    
    $totalStruct = @{}
    $currentWeekStruct = @{}

    (Get-ChildItem -Path $backupPath -Directory).Name | foreach {
        [string]$weekNumber = if((GetWeekOfYear (Get-CorrectDateFormat($_))) -eq $currentWeekNumber){"currentWeek"} else {(GetWeekOfYear (Get-CorrectDateFormat($_)))}
        if(!($totalStruct.ContainsKey($weekNumber)))
        {
            $totalStruct.Add($weekNumber, [string]($_ + " "))
        }
        else
        {
            $totalStruct.$weekNumber += [string]($_ + " ") 
        }
    }


    $totalStruct.Keys | %{
        $newest = " "
        if($_ -ne "currentWeek")
        {
            $totalStruct.$_.Split(' ') | %{
            
                if ($_ -gt $newest){$newest = $_}
            }
            $totalStruct.$_.Split(' ') | %{
            
                if (($_ -ne $newest) -and ($_ -ne "")){Remove-Item -Path "$backupPath\$_" -Force -Recurse}
            }
       
        }
        if($_ -eq "currentWeek")
        {
            $totalStruct.$_.Split(' ') | %{
                if($_ -ne ""){ 
                
                    [String]$day = (Get-Date (Get-CorrectDateFormat($_))).DayOfWeek.value__
                    if(!($currentWeekStruct.ContainsKey($day)))
                    {
                        $currentWeekStruct.Add($day, [string]($_ + " "))
                    }
                    else
                    {
                        $currentWeekStruct.$day += [string]($_ + " ") 
                    }
        
                }
       
            }
        }    
    }

    $currentWeekStruct.Keys | %{
        $newest = " "

        $currentWeekStruct.$_.Split(' ') | %{

            if ($_ -gt $newest){$newest = $_}
        }
        $currentWeekStruct.$_.Split(' ') | %{
            
            if (($_ -ne $newest) -and ($_ -ne "")){Remove-Item -Path "$backupPath\$_" -Force -Recurse}
        
        }

    } 
}
 Write-Host "Rotating of $backupFolder" 
 Do-BackupRotate $backupFolder