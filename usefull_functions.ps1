function Invoke-DatabaseQuery ([Parameter(Mandatory=$true)][string]$connectionString, [string[]]$query){

    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    $cmd=new-object system.Data.SqlClient.SqlCommand($query,$connection)
    $cmd.CommandTimeout=30
    $ds=New-Object system.Data.DataSet
    $da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
    [void]$da.fill($ds)
    #$ds.Tables
    $connection.close()
    return $ds.Tables
}
