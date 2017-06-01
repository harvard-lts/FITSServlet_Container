# FITSServlet_Container
FITS Servlet Docker Container
Pulling this package use: docker pull harvardlts/fitsservlet_container:latest

# Tagged Versions:
Versions are tagged by the version of FITS they contain and the platform the build is based on.
In general, Harvard is using AmazonLinux for these builds at the moment.  A build based on
Centos is planned but no time is set for when this build will be added.  The Centos branch will
eventually be added and made available.

# Using FITS Servlet
This build will deploy the FITS Web Service into a Tomcat container. The container exposes port 8080 for Tomcat.

FITS is available at http://[DOCKERIP]:8080/
The uploads interface is at http://[DOCKERIP]:8080/

More details can be found at http://projects.iq.harvard.edu/fits

# Licensing and Support
This build is offered As-Is with no support.

The overall package is licensed with FITS under the BSD license. By installing this package you are accepting an Oracle JDK license
which has been bundled with the build. The JDK is complete and unmodified.  If you do not wish to have an Oracle licensed solution
you should consider building a version of this using OpenJDK which has tested okay with FITS.
# Build Features:
There is a volume called /processing, if you attach local storage to this you can put files into the folder and then you can use the URL to examine them like follows:
http://[DOCKERIP]:8080/examine?file=/processing/[FILENAME]
