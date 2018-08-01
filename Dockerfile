FROM amazonlinux:latest
LABEL maintainer "Anthony Moulen <anthony_moulen@harvard.edu>"
ENV TOMCAT_MAJOR="8" \
    TOMCAT_VERSION="8.0.53" \
    FITS_VERSION="1.3.0" \
    FITSSERVLET_VERSION="1.1.3" \
    FITS_URL="http://projects.iq.harvard.edu/files/fits/files/fits" \
    CATALINA_HOME=/opt/tomcat \
    JAVA_DOWNLOAD=http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm
# Lazy download environment link, did this to avoid typing out the long URL all at once.  You can't use an ENV variable within the same ENV statement.
ENV TOMCAT_TAR=https://www.apache.org/dyn/closer.cgi?action=download&filename=tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

# Update Environment:
RUN echo "LANG=en_US.utf-8" >> /etc/profile.d/locale.sh && \
    echo "LC_ALL=en_US.utf-8" >> /etc/profile.d/locale.sh && \
    echo "export LANG LC_ALL" >> /etc/profile.d/locale.sh && \
    yum -y update && \
    yum -y install tar python27 python27-pip python2-setuptools gpg openssl wget unzip perl util-linux && \
    useradd -u 173 -s /sbin/nologin -d /opt/tomcat -m tomcat && \
    easy_install supervisor && \
    echo_supervisord_conf > /etc/supervisord.conf && \
    mkdir /etc/supervisor.d && \
    mkdir /var/lib/supervisor && \
    mkdir /var/log/supervisor && \
    chown tomcat /var/lib/supervisor && \
    chown tomcat /var/log/supervisor

# Copy in local configurations and utilities
COPY supervisord.conf /etc/
COPY supervisor/* /etc/supervisor.d/
COPY java_home.pl /opt/lts_utils/
COPY change_tomcat_id.sh /opt/lts_utils/
RUN mkdir /opt/fits && \
    mkdir /processing && \
    chown tomcat:tomcat /processing && \
    chown -R tomcat:tomcat /opt/lts_utils && \
    chmod +x /opt/lts_utils/* && \
    chown -R tomcat:tomcat /opt/fits

# Install Java on Amazon Linux:
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" $JAVA_DOWNLOAD && \
    yum localinstall -y jdk*rpm && \
    yum install -y jpackage-utils javapackages-tools

USER tomcat
# Install FITS Application
WORKDIR /opt/fits
RUN curl -o fits.zip $FITS_URL-$FITS_VERSION.zip && \
    unzip -q fits.zip && \
    rm fits.zip 
#    mv fits* REMOVEME && \
#    mv REMOVEME/* . && \
#    rmdir REMOVEME

# Install Tomcat from Apache, based on Tomcat DockerHub Package.
WORKDIR $CATALINA_HOME

RUN wget -O tomcat.tar.gz "$TOMCAT_TAR" && \
    tar -zxf tomcat.tar.gz --strip-components=1 && \
    rm bin/*.bat && \
    rm tomcat.tar.gz && \
    rm -rf webapps && \
    mkdir webapps

USER root
COPY *.properties $CATALINA_HOME/conf/
RUN chmod 775 /opt/lts_utils/* && \
    echo "JAVA_HOME=`/opt/lts_utils/java_home.pl`" >> /etc/java/java.conf && \
    chown -R tomcat:tomcat conf

USER tomcat
# Install FITS Servlet into WebApps folder as ROOT.
RUN curl -o $CATALINA_HOME/webapps/fits.war $FITS_URL-$FITSSERVLET_VERSION.war && \
    mkdir $CATALINA_HOME/webapps/ROOT && \
    echo '<% response.sendRedirect("/fits"); %>' > $CATALINA_HOME/webapps/ROOT/index.jsp

# Expose our Volume and Ports
VOLUME ["/processing"]
# Web Port
EXPOSE 8080 \
       8009 \
       8443

# Start up Tomcat 8
CMD ["/usr/local/bin/supervisord"]
