# User Acquisition Channel
This repo is to document the process and code for parsing utm labels (medium, source, campaign name) into business related acquisition channel.

## Version 1:  
I think for current stage it is enough to parse __utm_medium, utm_source and convert them into channel, sub-channel, platform, placement__  
The main channel we would like to know now are __organic, direct, internal referral, affiliate, ppc, referral and others__

The function itself can act like a documentation and process of how to group those channels. In addition, any new requirement can be easily added into the code and change the grouping rule

### Function(utm_parse):
__Input:__

1)utm medium  
2)utm source  
3)utm campaign  

__Output:__

1)channel  
2)sub-channel  
3)platform  
4)placement  
5)campaign name  

Related Cards  
https://redmine.deriv.cloud/issues/9989#
https://redmine.deriv.cloud/issues/9988#

PPC Campaign UTM Naming Rule  
https://docs.google.com/document/d/1-2RJ3yPQ_PUZlicUcWdjdkvWY9emFmTgnQk1KfR1Aq4/edit

PPC Campaign UTM Builder and Development Place    
https://docs.google.com/spreadsheets/d/1f2erU6Yr5-nC2f6GdCBoxYMO3LxpcXvrJSJG1m6f2yc/edit#gid=1453196576

Channel Grouping with Tableau  
https://10az.online.tableau.com/#/site/binary/views/ChannelGrouping/Channel?:iid=1
