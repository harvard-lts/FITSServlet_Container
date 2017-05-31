# FITSServlet_Container
FITS Servlet Docker Container

This build will deploy the FITS Web Service into a Tomcat container. The container exposes port 8080 for Tomcat.

FITS is available at http://[DOCKERIP]:8080/
The uploads interface is at http://[DOCKERIP]:8080/

More details can be found at http://projects.iq.harvard.edu/fits

This build is offered As-Is with no support.

# Build Features:
There is a volume called /processing, if you attach local storage to this you can put files into the folder and then you can use the URL to examine them like follows:
http://[DOCKERIP]:8080/examine?file=/processing/[FILENAME]
