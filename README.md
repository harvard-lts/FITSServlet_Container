| :exclamation:  This project has been archived |
|:-----------------------------------------------|
| The Docker functionality can now be found in [FITSServlet](https://github.com/harvard-lts/FITSServlet) |


# FITSServlet_Container
FITS Servlet Docker Container
Pulling this package use: docker pull harvardlts/fitsservlet_container:latest

# Tagged Versions:
The master branch will be based on the preferred operating system.  Current preferred operating system
is Centos 7.  With 1.5.0 release we still support AmazonLinux, but we have deprecated Centos 6 due to 
issues in getting and managing supervisor on this older platform.  

With 1.5.0 the latest release is Centos 7, the 1.5.0 tagged release is AmazonLinux, but there is a 1.5.0-centos7
available if you want to use that version specifically.  

# Using FITS Servlet
This build will deploy the FITS Web Service into a Tomcat container. The container exposes port 8080 for Tomcat.

FITS is available at http://[DOCKERIP]:8080/fits/
The uploads interface is at http://[DOCKERIP]:8080/fits/

More details can be found at http://projects.iq.harvard.edu/fits

# Licensing and Support
This build is offered As-Is with no support.

The overall package is licensed with FITS under the BSD license.

If you install a version older than 1.4.0 you are agreeing to accept the Oracle JDK License, which has
been bundled into the build.  Versions 1.4.0 and beyond are using OpenJDK and therefore you are agreeing
to the OpenJDK license.  

# Build Features:
There is a volume called /processing, if you attach local storage to this you can put files into the folder and then you can use the URL to examine them like follows:
http://[DOCKERIP]:8080/fits/examine?file=/processing/[FILENAME]
