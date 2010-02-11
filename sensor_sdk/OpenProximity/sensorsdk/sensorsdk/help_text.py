from django.utils.translation import ugettext as _

SensorCampaignAdmin=_('''A <b>SensorSDK campaign</b> is used to tell to which devices we try to <b>connect</b>.<br>
<br>
You can\'t use <b>SensorSDK</b> without having an <b>enabled</b> campaign first.<br>
Important fields are:<ul>
<li>Enabled.
<li>Address Filter.
<li>Name Filter.</ul>
<br>
<br>Plugin handling per device is handled by each plugin, <b>you don\'t have to worry about it</b>.''')

AlertDefinitionTemplateAdmin=_('''An <b>Alert Definition Template</b> is used to generate email content when an alert is triggered.<br>
<br>
You can only define one template per kind of alert available.<br>
<br>
The Syntaxis is the same used on Django templates, remember to add double brackets to each variable {{ variable }}.<br>
<br>
<h3>Available variables from SensorSDK</h3>
<ul>
    <li><b>value</b>: Value from the reading that triggered the alarm</li>
    <li><b>time</b>: Time when the alarm was triggered</li>
    <li><b>user</b>: User whose getting this email</li>
    <li><b>target</b>: Reference to the device that triggered the alarm. Available subset:
	<ul>
	    <li><b>target.address</b></li>
	    <li><b>target.name</b></li>
	    <li><b>target.mode</b></li>
	    <li><b>target.friendly_name</b></li>
	</ul>
    </li>
    <li><b>definition</b>:  Information related to the alarm definition
	<ul>
	    <li><b>definition.mode</b></li>
	    <li><b>definition.field</b></li>
	    <li><b>definition.set</b></li>
	    <li><b>definition.clr</b></li>
	    <li><b>definition.targets</b></li>
	    <li><b>definition.timeout</b></li>
	    <li><b>definition.users</b></li>
	</ul>
    </li>
</ul>
<br>
<br>
You can get more information on:
<ul>
<li><a href="http://www.opensensors.wikidot.com">OpenSensors Website</a></li>
<li><a href="http://www.openproximity.org">OpenProximity Website</a></li>
<li><a href="http://www.djangoproject.com/">Django Website</a></li>
</ul>
<br><br>
''')

AlertDefinitionAdmin=_('''An <b>Alert Definition</b> defines the conditions for alarms to be triggered.<br>
<br>
There are four types of alarms:<ul>
<li><b>Under Range</b></li>
<li><b>Over Range</b></li>
<li><b>In Range</b></li>
<li><b>No data</b></li>
</ul>
<br>
<br>
All this types of alarms except for <b>No data</b> need a <b>set</b> and a <b>clear</b> value. 
This values will define when an alarm condition is met.
<br>
<br>
<b>No Data</b> is an special kind of alarm which is sent when more than <b>set</b> seconds are elapsed
without any data from the monitored devices.
<br>
<br>
For more information check <a href="http://opensensors.wikidot.com">OpenSensors Website</a>
<br><br>
''')
