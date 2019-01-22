# FITSServlet_Container
FITS Servlet Docker Container
Pulling this package use: docker pull harvardlts/fitsservlet_container:latest

# Tagged Versions:
The master branch will be based on the preferred operating system.  Today we are targeting
AmazonLinux as the preferred platform.  In the near future we will be changing this to Centos 7.  
The Centos branch is based on Centos 6 and is there for individuals on legacy docker environments
running on Centos 6 or a similar kernel.  This environment will eventually be deprecated,  
likely with FITS 1.5.x.  An AmazonLinux branch is planned when Centos 7 release is built, this
will contain our legacy AmazonLinux build which we will maintain while it isn't a lot of additional work.

# Using FITS Servlet
This build will deploy the FITS Web Service into a Tomcat container. The container exposes port 8080 for Tomcat.

FITS is available at http://[DOCKERIP]:8080/fits/
The uploads interface is at http://[DOCKERIP]:8080/fits/

More details can be found at http://projects.iq.harvard.edu/fits

# Licensing and Support
This build is offered As-Is with no support.

The overall package is licensed with FITS under the BSD license.

If you install a version older than 1.4.0 you are agreeing to accep tthe Oracle JDK License, which has
been bundled into the build.  Versions 1.4.0 and beyond are using OpenJDK and therefore you are agreeing
to the OpenJDK license.  

# Build Features:
There is a volume called /processing, if you attach local storage to this you can put files into the folder and then you can use the URL to examine them like follows:
http://[DOCKERIP]:8080/examine?file=/processing/[FILENAME]
