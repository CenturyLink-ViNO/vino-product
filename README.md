# ViNO

## Requirements

Before you download and build the ViNO project, make sure that your
system meets the following requirements:
### **Hardware requirements**
Your development workstation should meet or exceed these hardware
requirements:
  - At least 2 CPUs
  - At least 20 GB of free disk space to checkout and build the source
    code
  - You need at least 4 GB of RAM.
  - Internet connection
### **Software requirements**
The ViNO project is traditionally developed and tested on CentOS release
7.7 Minimal
([CentOS-7-x86\_64-Minimal-1908.iso](http://mirrors.mit.edu/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso)),
but other distributions may be used.

Your workstation must have the software listed below. See Establishing a
Build Environment for additional required packages and the commands to
install them.

  - Java 8
  - Ant
  - Git
  - Docker
  - Ruby
  - NodeJS
  - ESLint
  - Lessc
  - Typescript

## Establishing a Build Environment (CentOS/RHEL)

This section describes how to set up your local work environment to
build the ViNO project.

**Installing the JDK (Java 8)**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo yum install java-1.8.0-openjdk-devel</code></pre></td>
</tr>
</tbody>
</table>

**Installing Ant**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo yum install ant ant-contrib</code></pre></td>
</tr>
</tbody>
</table>

****Installing EPEL repository****

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo yum install epel-release</code></pre></td>
</tr>
</tbody>
</table>

**Installing required packages**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo yum install git docker jq nodejs</code></pre></td>
</tr>
</tbody>
</table>

**Setting up the environment**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo npm i -g less
sudo npm i -g eslint@5.14.1
sudo npm i -g typescript@3.3.3
sudo npm i -g @typescript-eslint/parser@1.7.0
sudo npm i -g @typescript-eslint/eslint-plugin@1.7.0</code></pre></td>
</tr>
</tbody>
</table>

**Setting up Docker**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>// Create the docker group and add your user
sudo groupadd docker
sudo usermod -aG docker &lt;user&gt;

// Log out and log back in so that your group membership is re-evaluated

// Configure Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

// Check if it works
docker run hello-world</code></pre></td>
</tr>
</tbody>
</table>

## Establishing a Build Environment (Ubuntu/Debian)

This section describes how to set up your local work environment to
build the ViNO project.

**Installing the JDK (Java 8)**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo apt-get install openjdk-8-jdk</code></pre></td>
</tr>
</tbody>
</table>

**Installing Ant**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo apt-get install ant ant-contrib</code></pre></td>
</tr>
</tbody>
</table>

**Installing required packages**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo apt-get install git jq nodejs npm libxml2-utils node-less</code></pre></td>
</tr>
</tbody>
</table>

**Setting up the environment**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo npm i -g eslint@5.14.1
sudo npm i -g typescript@3.3.3
sudo npm i -g @typescript-eslint/parser@1.7.0
sudo npm i -g @typescript-eslint/eslint-plugin@1.7.0</code></pre></td>
</tr>
</tbody>
</table>

**Setting up Docker**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository &quot;deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable&quot;

sudo apt-get install docker-ce

// Create the docker group and add your user
sudo groupadd docker
sudo usermod -aG docker &lt;user&gt;

// Log out and log back in so that your group membership is re-evaluated

// Configure Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

// Check if it works
docker run hello-world</code></pre></td>
</tr>
</tbody>
</table>

## Downloading the Source and Build

The ViNO source tree is located here
<https://github.com/CenturyLink-ViNO/vino-product>  
This document describes how to download the source tree and build the
ViNO Project.  
  

**<span style="color: rgb(32,33,36);">Create a working
directory</span>**

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>mkdir product_vino
cd product_vino</code></pre></td>
</tr>
</tbody>
</table>

**Clone the ViNO-product repository:**

**IMPORTANT**: it is HIGHLY recommended that you use Git over SSH to
clone the project.

You can find more information on how to setup Git over SSH
[here](https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

If you want to proceed using Git over HTTPS instead, click
[here](https://github.com/CenturyLink-ViNO/vino-product#clone-the-vino-product-repository-using-https).

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>git clone git@github.com:CenturyLink-ViNO/vino-product.git</code></pre></td>
</tr>
</tbody>
</table>

Checkout the 'master' branch:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>cd vino-product/
git checkout master</code></pre></td>
</tr>
</tbody>
</table>

Run the bootstrap script (do this for every terminal window that you
want to use for this project).

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>source product.settings/bootstrap/bootstrap.sh</code></pre></td>
</tr>
</tbody>
</table>

This will place you in the product\_vino/ directory.

Execute thin to make sure that all dependencies are in place:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>ant check</code></pre></td>
</tr>
</tbody>
</table>

Now you can build.

The ant git.update is optional.

The 'ant clean-all' will clear the build directory and cause everything
to get built.

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>ant git.update
ant clean-all
ant</code></pre></td>
</tr>
</tbody>
</table>

The result of the build process is a compressed file (tar.gz) located in
the build/bin folder:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>ls build/bin/
vino-product-docker.0.0.0-YYMMDD_HHMM.tar.gz</code></pre></td>
</tr>
</tbody>
</table>

### Modifying the project

<span style="color: rgb(0,0,0);">The ViNO project is a collection of
repositories that are built together to create a product.</span>

<span style="color: rgb(0,0,0);">Before you start modifying the source
code, first, you will need to identify which repository you want to
change.</span>

You will find a list of all repositories used by ViNO in this file:

**product\_vino/vino-product/product.settings/product.properties.xml**

This file contains a list of repositories to checkout and build. There
is also a group (shared) with definitions that usually are common to all
repositories like Bitbucket URL, base clone directory, and ref
(branch).  
  
For each repository line we have:

**name**: name of the repository on Bitbucket  
**prefix**: type of the repository, usually: lib, forks, components,
drivers, or lib-web; it also corresponds to the directory that the
repository will be cloned.  
**target**: Ant target to build the repository - OPTIONAL: you only need
to inform it if it is different from the repository name  
**cloneDir**: clone directory - OPTIONAL: you only need to inform it if
is different from ${tree.top}/${prefix}/${name}  
**ref**: branch to clone - OPTIONAL: you only need to inform it if is
different from the common branch (master)

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot; standalone=&quot;no&quot;?&gt;
&lt;repositories&gt;
   &lt;shared&gt;
      &lt;common url=&#39;git@github.com:CenturyLink-ViNO&#39; cloneDirectory=&#39;${tree.top}&#39; ref=&#39;master&#39;/&gt;
   &lt;/shared&gt;
   &lt;repos&gt;
      &lt;repository name=&#39;dev-env-public&#39;                 prefix=&#39;tools/dev-env&#39; target=&#39;DO-NOT-BUILD&#39;             cloneDirectory=&#39;${tree.top}/tools/dev-env/public&#39;/&gt;
      &lt;repository name=&#39;abacus-shell-libs-vino&#39;         prefix=&#39;components&#39;    target=&#39;abacus-shell-libs&#39;        cloneDirectory=&#39;${tree.top}/components/abacus-shell-libs&#39;/&gt;
      &lt;repository name=&#39;abacus-postgres-vino&#39;           prefix=&#39;components&#39;    target=&#39;abacus-postgres&#39;          cloneDirectory=&#39;${tree.top}/components/abacus-postgres&#39;/&gt;
      &lt;repository name=&#39;lib-java-webui-vino&#39;            prefix=&#39;lib&#39;           target=&#39;lib-java-web-ui&#39;          cloneDirectory=&#39;${tree.top}/lib/lib-java-web-ui&#39;/&gt;
      &lt;repository name=&#39;abacus-nodelib-util&#39;            prefix=&#39;lib&#39;           target=&#39;DO-NOT-BUILD&#39;/&gt;
      &lt;repository name=&#39;jquery-fork&#39;                    prefix=&#39;forks&#39;         target=&#39;DO-NOT-BUILD&#39;             cloneDirectory=&#39;${tree.top}/forks/web-jquery-fork&#39;             ref=&#39;vino-master&#39;/&gt;
      &lt;repository name=&#39;abacus-jquery-vino&#39;             prefix=&#39;lib-web&#39;       target=&#39;abacus-jquery&#39;            cloneDirectory=&#39;${tree.top}/lib-web/abacus-jQuery&#39;/&gt;
      &lt;repository name=&#39;twitter-bootstrap-fork-vino&#39;    prefix=&#39;forks&#39;         target=&#39;DO-NOT-BUILD&#39;             cloneDirectory=&#39;${tree.top}/forks/web-bootstrap-fork&#39;          ref=&#39;vino-master&#39;/&gt;
      &lt;repository name=&#39;abacus-twitter-bootstrap-vino&#39;  prefix=&#39;lib-web&#39;       target=&#39;abacus-twitter-bootstrap&#39; cloneDirectory=&#39;${tree.top}/lib-web/abacus-twitter-bootstrap&#39;/&gt;
      &lt;repository name=&#39;abacus-lib-js-ots-vino&#39;         prefix=&#39;lib-web&#39;       target=&#39;DO-NOT-BUILD&#39;             cloneDirectory=&#39;${tree.top}/lib-web/abacus-lib-js-ots&#39;/&gt;
      &lt;repository name=&#39;vino-opensource-customizations&#39; prefix=&#39;lib&#39;           target=&#39;DO-NOT-BUILD&#39;             cloneDirectory=&#39;${tree.top}/lib/vino-opensource-customizations&#39;/&gt;
      &lt;repository name=&#39;vino-node-red-nodes&#39;            prefix=&#39;components&#39;    target=&#39;vino-node-red-nodes&#39;/&gt;
      &lt;repository name=&#39;vino-core-nodes&#39;                prefix=&#39;components&#39;    target=&#39;vino-core-nodes&#39;/&gt;
      &lt;repository name=&#39;vino-core&#39;                      prefix=&#39;components&#39;    target=&#39;vino-core&#39;/&gt;
      &lt;repository name=&#39;vino-docker&#39;                    prefix=&#39;components&#39;    target=&#39;vino-docker&#39;/&gt;
      &lt;repository name=&#39;vino-product&#39;                   prefix=&#39;&#39;              target=&#39;vino&#39; /&gt;
   &lt;/repos&gt;
&lt;/repositories&gt;</code></pre></td>
</tr>
</tbody>
</table>

### **Clone the ViNO-product repository using HTTPS:**

If you want to proceed using Git over HTTPS instead (which is not
recommended) execute:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>export GIT_OVER_HTTPS=y</code></pre></td>
</tr>
</tbody>
</table>

Clone the main project:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>git clone https://github.com/CenturyLink-ViNO/vino-product.git</code></pre></td>
</tr>
</tbody>
</table>

Checkout the 'master' branch:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>cd vino-product/
git checkout master</code></pre></td>
</tr>
</tbody>
</table>

Run the bootstrap script (do this for every terminal window that you
want to use for this project).

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>source product.settings/bootstrap/bootstrap.sh</code></pre></td>
</tr>
</tbody>
</table>

This will place you in the product\_vino/ directory.

Now you need to edit the
**vino-product/product.settings/repos.properties.xml** file and replace
the "common url" property with the SSH URL:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>&lt;shared&gt;
   &lt;common url=&#39;git@github.com:CenturyLink-ViNO&#39; cloneDirectory=&#39;${tree.top}&#39; ref=&#39;master&#39; /&gt;
&lt;/shared&gt;</code></pre></td>
</tr>
</tbody>
</table>

with the HTTS URL:

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>&lt;shared&gt;
   &lt;common url=&#39;https://github.com/CenturyLink-ViNO&#39; cloneDirectory=&#39;${tree.top}&#39; ref=&#39;master&#39; /&gt;
&lt;/shared&gt;</code></pre></td>
</tr>
</tbody>
</table>

Now you can build.

The ant git.update is optional.

The 'ant clean-all' will clear the build directory and cause everything
to get built.

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>ant git.update
ant clean-all
ant</code></pre></td>
</tr>
</tbody>
</table>

The result of the build process is a compressed file (tar.gz) located in
the build/bin folder

<table>
<colgroup>
<col style="width: 100%" />
</colgroup>
<tbody>
<tr class="odd">
<td><pre><code>ls build/bin/
vino-product-docker.0.0.0-YYMMDD_HHMM.taz.gz</code></pre></td>
</tr>
</tbody>
</table>
