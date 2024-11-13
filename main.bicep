@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Display name of the alert rule')
param displayName string

@description('Severity of the alert')
@allowed([
  'High'
  'Medium'
  'Low'
  'Informational'
])
param severity string = 'High'

@description('Kusto Query Language (KQL) query for the alert rule')
param query string = 'BloodHoundLogs_CL | where data_type == "nothing"'

@description('Frequency at which the query is run (ISO 8601 duration format)')
param queryFrequency string = 'PT1H'

@description('Time span over which data is analyzed (ISO 8601 duration format)')
param queryPeriod string = 'PT1H'

@description('Operator used to compare the result of the query against the threshold')
@allowed([
  'GreaterThan'
  'LessThan'
  'Equal'
  'NotEqual'
])
param triggerOperator string = 'GreaterThan'

@description('Threshold value for triggering the alert')
param triggerThreshold int = 0

@description('Description of the alert rule')
param alert_rule_description string = ''

@description('List of MITRE ATT&CK tactics associated with the alert')
param tactics array = []

@description('List of MITRE ATT&CK techniques associated with the alert')
param techniques array = []

@description('Determines if the alert is enabled')
param enabled bool = true

resource laWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
}

// Alert Rules are extensions of the Microsoft.SecurityInsights resource provider
// therefore the resource type is Microsoft.OperationalInsights/workspaces/providers/alertRules
// And the name of the alert rule is constructed as follows:
// {workspaceName}/Microsoft.SecurityInsights/{displayName}

resource alertRule 'Microsoft.SecurityInsights/alertRules@2022-11-01-preview' = {
  name: displayName
  scope: laWorkspace
  kind: 'Scheduled'
  properties: {
    displayName: displayName
    description: alert_rule_description
    severity: severity
    enabled: enabled
    query: query
    queryFrequency: queryFrequency
    queryPeriod: queryPeriod
    triggerOperator: triggerOperator
    triggerThreshold: triggerThreshold
    tactics: tactics
    techniques: techniques
    suppressionDuration: 'PT5H'
    suppressionEnabled: false
    incidentConfiguration: {
      createIncident: true
    }
  }
}
