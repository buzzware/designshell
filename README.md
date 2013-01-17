# DesignShell

DesignShell aims provide a smooth workflow for web designers by integrating and providing a safe and comfortable interface to :

* git
* git deployment
* SASS and other template languages via [middleman](http://middlemanapp.com)
* a git repository server like [BitBucket](http://bitbucket.org) or [GitHub](http://github.com) for simple repository duplication
* a secure keychain like the built-in MacOS one or a Windows equivalent to store security credentials

## Git Deployment Server (DesignShell Server)

DesignShell Server is a script that runs behind sshd, providing ultimate security. It receives commands from DesignShell eg. to deploy a git repository containing a .deploy_plan.xml file. The deploy plan contains details of target servers and what folders within the repository should be deployed where. A single deploy plan can describe how to deploy one folder to a shared host and another to BigCommerce. It also contains references to the keychain for passwords etc.

### Security

DesignShell Server keeps a cache of repositories it has deployed, so that redeploys can be very fast. While it must keep keys to access your git repositories, all other credentials are passed on the fly through ssh and not stored. There is no need for this server to even provide web access. Assuming you configure sshd properly and keep your keys safe, a hacker must break sshd to get in, and if they can do that, the entire internet is at risk.

### Fast Versioned Deployment

Waiting for a machine to complete a task is not conducive to a smooth workflow. DesignShell Server aims to provide ultimate speed in updating a site from local file changes, and enables experimentation with version control previously impossible with FTP/WebDAV based sites. DesignShell Server can also be located as close as possible to target servers so that file transfers are between nearby servers over high-speed links - much faster than international or domestic ADSL links.

####1. When you wish to push local changes to the git server, type :

	> ds push "some changes"

This is equivalent to :

	> git commit -am "some changes" && git push

Git compresses and sends only your changes to the git server eg. BitBucket or GitHub.

####2. When you want to deploy the changes you just pushed, to your web site, type :

	> ds deploy

This will tell DesignShell Server to update the target web site(s) to the latest git commit. If DesignShell Server has done this before, it will already have a git working copy in its cache and will only have to update it. Otherwise it will do a complete checkout. DesignShell Server also knows what commit the website is deployed to. This means it can work out exactly what files need to be transferred or removed to make the website match the target commit, from any previous commit the site was previously deployed to.

####3. When you want to wind back changes eg. when something has broken the site

	> ds log              # to see past commits and comments to choose from

	> ds deploy <commit>  # to move the web site to the given commit eg. before the site broke

As DesignShell Server knows what commit a site is deployed to, and git can work out the necessary changes between any two commits, DesignShell Server can transition a web site forward and backward in time, and between branches very efficiently.

# Frequently Asked Questions

### Why a *command line* tool for designers ?

Ruby is my favourite language, and much of what is required is already provided by Ruby gems. DesignShell Server needs to run on Linux and be easily deployed (RubyGems solves this). A Ruby command line tool can easily be made cross-platform for MacOS X, Windows and Linux. Also the task at hand should work well in the command line as it is easy to repeat commands, see history, scroll through output, copy and paste etc. The user would typically be using the arrow and enter keys to repeat commands more than they would be typing them.

### Why BitBucket? GitHub is much more awesome!

Calm down and compare the pricing plans ([here](http://github.com/plans) and [here](https://bitbucket.org/plans)) for the target audience - web design agencies. If you have 10 users and >125 website projects in private repositories (you wouldn't make client projects public would you?) in a years time, you'll be paying GitHub $200 month forever, unless you take some down. On BitBucket you'll only be paying $10/month for unlimited private repositories, or free for up to 5 users.

# Version One

I am aiming for Version One to include :

* DesignShell: Mac OSX support only (Linux will probably work too; Windows support is possible if someone wants to pay me)
* DesignShellServer: Ubuntu Linux support only (will probably work on Mac too)
* equivalents for general git commands eg. commit, push, pull, log etc
* deployment of any commit to WebDAV only (FTP later)
* storing of passwords etc in OSX keychain only (Windows equivalent later if needed)
* only basic git server functionality eg. list repos and only BitBucket
* basic middleman wrapper eg. build and server commands
* "ds publish" command that will commit, push and deploy

# Current Status

There is still a fair bit to do, but the most interesting part is working - git deployment via an external server. The user interface is very rough at present, while the background code is further ahead. DesignShell is distributed and installed as a gem. DesignShell Server installing requires copying and editing a wrapper script, which isn't too bad. The main subsystems including git, WebDAV, OSX keychain, deploy plan, and BitBucket are basically working. They use existing gems, so much of the hard work is done.

My current focus is on :

* middleman build
* progress reporting from DesignShell Server
* ds user interface

# DesignShell client Installation

1. gem install designshell
2. setup your ~/.ssh/config like this :

	Host designshell_des
	        Hostname dss.mydomain.com
	        IdentityFile /Users/gary/.ssh/designshell_des
	        User designshell
	        Port 22
	        PasswordAuthentication no
	        ChallengeResponseAuthentication no
	        PreferredAuthentications publickey


3. create a file ~/.credentials.xml containing :

	<?xml version='1.0' encoding='UTF-8'?>
		<Credentials>
		<simpleItems namespace='DesignShell'>
		<item name='deploy_host'>hive2_des</item>
		</simpleItems>
	</Credentials>

# DesignShell Server Installation

You will need an experienced UNIX administrator for this

1. add a new user eg. designshell
2. gem install designshell
3. create a cache folder eg. /home/designshell/designshell_cache
4. create a file /home/designshell/.credentials.xml containing :

	<?xml version='1.0' encoding='UTF-8'?>
	<Credentials>
		<simpleItems namespace='DesignShell'>
			<item name='cache_dir'>/home/designshell/designshell_cache</item>
		</simpleItems>
	</Credentials>

5. copy gems/designshell-0.0.x/designshelld-wrapper-example.sh to a home bin folder, chmod it to be executable and edit it
6. setup sshd for public key authentication with authorized_keys2 like this :

	command="/home/designshell/.bin/designshelld-wrapper.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-rsa AAAAB3NzaC...

7. on the client try "ssh designshell_des". You should get a prompt.
8. You will also need to setup ssh key access to your BitBucket repositories, adding the server id_dsa.pub key as a "deployment key" on each repository
