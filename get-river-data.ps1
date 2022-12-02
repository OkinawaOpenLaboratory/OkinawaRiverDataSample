Function Main {
    $waterLevels,$rains = Fetch-RiverData
    $waterLevels = $(Filter-Past1Hour $waterLevels)
    $rains = $(Filter-Past1Hour $rains)
    $waterLevels = $(Transform-WaterLevels $waterLevels)
    $rains = $(Transform-Rains $rains)
    Update-WaterLevels $waterLevels
    Update-Rains $rains
}

Function Fetch-RiverData {
    Write-Host "--河川水位データ(10分毎の水位と雨量)を取得"
    $response = Invoke-WebRequest "http://www.bousai.okinawa.jp/river/kasen/dat_js/DBDAT_dat.js"
    #UTF-8への変換とJSON化
    $formattedJsonText = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]:: `
                         GetEncoding("UTF-8").GetBytes($response.Content.Replace("gDat = ", "").Replace(";", "")))
    #Hashtableへ変換
    $data = $(ConvertFrom-Json $formattedJsonText)
    Return $($data.rep_suii10min),$($data.rep_rain10min)
}

Function Filter-Past1Hour($items) {
    $toDate = Get-Date
    $toDate = $toDate.AddHours(9)
    $fromDate = $toDate.AddHours(-1)
    $newItems = @()
    Foreach($item in $items){
        $dateTime = [Datetime]::ParseExact($item.tim, "MM/dd HH:mm", $null)
        If(($dateTime -lt $toDate) -And ($dateTime -gt $fromDate)) {
            $newItems += $item
        }
    }
    Return $newItems
}

Function Transform-WaterLevels($times) {
    $riverInfos = Fetch-RiverInfos

    $newItems = @()

    Foreach($time in $times){
        Foreach($waterLevel in $time.sdat){
            $timestamp = [Datetime]::ParseExact($time.tim, "MM/dd HH:mm", $null)
            $riverInfo = $(Search-RiverInfoBySNO $riverInfos 4 $waterLevel.sno)
            $alm = $riverInfo.alm -ne "－"
            $newItems += @{timestamp=$timestamp
                           sno=$waterLevel.sno
                           kind=$riverInfo.kind
                           cam=$riverInfo.cam
                           area=$riverInfo.area
                           stn=$riverInfo.stn
                           rgrp=$riverInfo.rgrp
                           ksn=$riverInfo.ksn
                           offc=$riverInfo.offc
                           lat=$riverInfo.lat
                           lon=$riverInfo.lon
                           alm=$alm
                           waterLevel=$waterLevel.dat[0].dat}
        }
    }
    Return $newItems
}

Function Transform-Rains($times){
    $riverInfos = Fetch-RiverInfos

    $newItems = @()

    Foreach($time in $times){
        Foreach($rain in $time.sdat){
            $timestamp = [Datetime]::ParseExact($time.tim, "MM/dd HH:mm", $null)
            $riverInfo = $(Search-RiverInfoBySNO $riverInfos 1 $rain.sno)
            $newItems += @{timestamp=$timestamp
                           sno=$rain.sno
                           kind=$riverInfo.kind
                           area=$riverInfo.area
                           stn=$riverInfo.stn
                           rgrp=$riverInfo.rgrp
                           ksn=$riverInfo.ksn
                           offc=$riverInfo.offc
                           lat=$riverInfo.lat
                           lon=$riverInfo.lon
                           rain=$rain.dat[0].dat}
        }
    }
    Return $newItems
}

Function Fetch-RiverInfos() {
    $response = Invoke-WebRequest "http://www.bousai.okinawa.jp/river/kasen/dat_js/DBDAT_inf.js"
    $formattedJsonText = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]:: `
                         GetEncoding("UTF-8").GetBytes($response.Content.Replace("gInf = ", "").Replace(";", "")))
    $data = $(ConvertFrom-Json $formattedJsonText)
    Return $data.stn
}

Function Search-RiverInfoBySNO($riverInfos, $kind, $sno) {
    $targetRiverInfo = @{}
    foreach($riverInfo in $riverInfos){
        if(($riverInfo.kind -eq $kind) -and ($riverInfo.sno -eq $sno)){
            $targetRiverInfo = $riverInfo
            break
        }
    }
    Return $targetRiverInfo
}

Function Update-WaterLevels($data) {
    $waterLevels = $(Get-Content -Path "./waterLevels.json" | ConvertFrom-Json)
    $data = $($data | ConvertTo-Json | ConvertFrom-Json)
    $waterLevels += $data
    ConvertTo-Json $waterLevels -Depth 100 | Out-File "./waterLevels.json" -Encoding utf8
}

Function Update-Rains($data) {
    $rains = $(Get-Content -Path "./rains.json" | ConvertFrom-Json)
    $data = $($data | ConvertTo-Json | ConvertFrom-Json)
    $rains += $data
    ConvertTo-Json $rains -Depth 100 | Out-File "./rains.json" -Encoding utf8
}

Main
