RolesCreator - v0.1
====================
<br/>
<b>Synopsis</b>
<br/>
A small robust command line utility to assist in the creation of roles and role entitlements as used by identity and access management provisioning systems.  Can be run
either as a native Ruby application or using the warbler package Java Jar.
<br/>
<br/>
<b>Features</b>
<br/>
Role Creation - creates roles and user memberships based on functional business/customer groupings as used by identity management provisioning tools.
<br/>
Role Entitlements - assigns entitlements to roles based on analysis of role member system accounts.
<br/>
User Exceptions - identifies any entitlements that are directly assigned to a user and not assigned via a role
<br/>
No persistent storage needed.  Purely a 'run time' analytics engine.
<br/>
<br/>
<b>Inputs</b>
<br/>
CSV files from authoritative source containing user identities and a CSV file containing system accounts and entitlements
<br/>
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
<br/>
<br/>
<b>Structure</b>
<br/>
The sample_data/ directory contains 4 sample data files that can be used to demonstate the utility.  Identities.csv is an auth source example, with 
sample entitlements files for an LDAP, MS-SQL database and Unix system.
<br/>
The config/ directory contains the config.yml file for settings.
<br/>
The bin/ and lib/ directories contain the core system files written in MRI Ruby.
<br/>
The docs/ directory contains a Quick Start PDF
<br/>
The RolesCreator.jar is a warbler packaged self-contained version of the app that can be run on systems without Ruby or JRuby installed.
<br/>
To run either use run_rolescreator.sh for if you have Ruby installed, or run_rolescreator_java.sh for the Jar version. 