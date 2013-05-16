RolesCreator - Roles Creator and Access Exceptions Engine
=========================================================
<br/>
<b>Features</b>
<br/>
Role Creation - creates roles and user memberships based on functional business/customer groupings
<br/>
Role Entitlements - assigns entitlements to roles based on analysis of role member system accounts
<br/>
User Exceptions - identifies any entitlements that are directly assigned to a user and not assigned via a role
<br/>
No persistent storage needed.  Purely a 'run time' analytics engine.
<br/>
<b>Inputs</b>
<br/>
CSV files from authoritative source containing user identities and a CSV file containing system accounts and entitlements
<br/>
<b>Outputs</b>
<br/>
3 files - role:users; role:entitlements; user:entitlement exceptions
<br/>
Files can be exported to XML, JSON or CSV format.
<br/>
Currently only analyses one system per run.  If multiple systems require role analysis, simply run more than once with new input files.
<br/>
Edit the config.yml with appropriate data input parameters and system requirements.  Can extend existing roles if made available in CSV input.