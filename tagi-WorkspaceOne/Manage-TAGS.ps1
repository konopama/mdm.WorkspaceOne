<#
0. Get-TagList to display list of Tags available in AirWatch (optional)
1. Get-SerialsList -FilePatch .... to load list of serial numbers to variable $global:Serials
2. Add-TagToDevices - function to initiate process of add tag to list of devices in $global:Serials

Additiolan functions

Add-TagToDevice ($TagID, $DevSerial) - add tag to device wih serial. The function is use with foreach loop to add TAg to number of devices
remove-TagToSerial ($TagID, $DevSerial) - remove tag from device wih serial. The function is use with foreach loop to remove TAg from number of devices
Remove-TagFromDevices - remove TAg from devices in $global:Serials

#>

#Clear all variables before proceed with new devices
#$sysvars = Get-Variable | select -ExpandProperty Name
#$sysvars += 'sysvars'
#Get-Variable | where {$sysvars -notcontains $_.Name} |foreach {Remove-Variable $_}




#$global:TagId = 10020 #Outlook@Danone_0
#$global:TagId = 10024 #deviceToRemove
$global:TagId = 10077 #test tag
#$global:TagId = 10028 #newStructure
#$global:TagId = 10032 #MI TOUCH ELN CORE ON DEMAND


#define excludes for process. 
$global:Serials = @()
$global:Excludes = @()
$global:Excludes += '0123456789ABCDEF' #no-name devices with Android (199 devices in MWA)
$global:patch = 'z:'

# Get serials from txt file
# One serial per line with no separator
function Get-SerialsList ($FilePatch) {
    
    if ($FilePatch) {
        $global:Serials = Get-Content $FilePatch        
        "Number of devices imported to script: {0}." -f $global:Serials.count | Write-Host -ForegroundColor Green
    } else {
        Write-Host -BackgroundColor Red "Please define FilePatch variable"
    }
}


#Function to get list of TAGS from AirWatch
function Get-TagList {

    $nURI=$uri + "v1/mdm/tags/search?organizationgroupid=570"
    $TagsList=Invoke-RestMethod -Method Get -Uri $nURI -Headers $headers -ContentType $ContentType -Credential $Credentials #-Body $Body
    $TagsList.Tags | select id, Tagname, Tagavatar | Out-GridView
}


#Function to add TAg to Device
function add-TagToDevice ($TagID, $DevSerial) {
    
    #get devices details
    $dURI = $URI + 'mdm/devices/' + $DevSerial
    $DevDetails =  Invoke-RestMethod -Method get -Uri $dURI -Headers $headers -ContentType $ContentType -Credential $Credentials #-Body $Body
    $DevID = ($DevDetails.Id).Value
    $dID = [string]$DevID
    $tURI = $URI + "mdm/tags/$TagID/adddevices"

    $resobj= @{
        'BulkValues' = @{'Value' = @($dID)}      
    }

    $Body = $resobj | ConvertTo-Json -Depth 3
    
    if ($global:Excludes -notcontains $DevSerial) {
        $res = Invoke-RestMethod -Method Post -Credential $Credentials -Uri $tURI -Body $Body -ContentType $ContentType -Headers $headers
        Return $res
    }

}


#Function to add TAg to User
function add-TagToUser ($TagID, $DevSerial) {
    
    #get devices details
    $dURI = $URI + 'mdm/devices/search?user=' + $DevSerial
    $DevDetails =  Invoke-RestMethod -Method get -Uri $dURI -Headers $headers -ContentType $ContentType -Credential $Credentials #-Body $Body
    $DevID = (($DevDetails.Devices).Id).Value
    #$dID = [string]$DevID
    $dID = $DevID
    $tURI = $URI + "mdm/tags/$TagID/adddevices"

    $resobj= @{
        'BulkValues' = @{'Value' = @($dID)}      
    }

    $Body = $resobj | ConvertTo-Json -Depth 3
    
    if ($global:Excludes -notcontains $DevSerial) {
        $res = Invoke-RestMethod -Method Post -Credential $Credentials -Uri $tURI -Body $Body -ContentType $ContentType -Headers $headers
        Return $res
    }

}



#Process add Tag to devices in $global:Serials
function Add-TagToDevices {
    
    if ($global:Serials) {
        
        $vCount = $global:serials.Count
        $aw_TagID = $global:TagId  
        "You are starting to update devices in AirWatch. `nPlease make sure that Tag id {0} is correct and device serials count {1} is ok." -f $aw_TagID, $vCount | write-Host -ForegroundColor Yellow 
        
        $decision = Read-Host -Prompt "Press Y to continue or other key to cancell process"
        
        $counter = 0
        
        if ($decision -eq 'Y') {

            foreach ($srl in $global:serials) {

                Write-Progress -Activity "Checking in progress - $counter / $vCount - Problems detected: $global:vProblemCount" -CurrentOperation $vserver.AD_ComputerName -PercentComplete (($counter / $vCount)*100)
                $res = add-TagToDevice -TagID $aw_TagID -DevSerial $srl
                $fname = "$global:patch"+"addTAG-$srl.txt"
                $res | Out-File $fname
                $counter++

            }

        } else {
            Write-host -ForegroundColor Red "Process Cancelled"
        }
    } else {Write-host -ForegroundColor Red "Please import serial numbers first"}
}

function Add-TagToUsers {
    
    if ($global:Serials) {
        
        $vCount = $global:serials.Count
        $aw_TagID = $global:TagId  
        "You are starting to update devices in AirWatch. `nPlease make sure that Tag id {0} is correct and device serials count {1} is ok." -f $aw_TagID, $vCount | write-Host -ForegroundColor Yellow 
        
        $decision = Read-Host -Prompt "Press Y to continue or other key to cancell process"
        
        $counter = 0
        
        if ($decision -eq 'Y') {

            foreach ($srl in $global:serials) {

                Write-Progress -Activity "Checking in progress - $counter / $vCount - Problems detected: $global:vProblemCount" -CurrentOperation $vserver.AD_ComputerName -PercentComplete (($counter / $vCount)*100)
                $res = add-TagToUser -TagID $aw_TagID -DevSerial $srl
                $fname = "$global:patch"+"addTAG-$srl.txt"
                $res | Out-File $fname
                $counter++

            }

        } else {
            Write-host -ForegroundColor Red "Process Cancelled"
        }
    } else {Write-host -ForegroundColor Red "Please import serial numbers first"}
}



