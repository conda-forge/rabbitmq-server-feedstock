#!/bin/bash -ef

cp_envsubst()
{
	src=$1
	dst=$2
	if [ -d $dst ]; then
		dst="$dst/$(basename $src)"
	fi
	cat $src | envsubst '${PREFIX}' > $dst
}

# Export license
cp -n src/LICENSE .

RABBITMQ_HOME=${PREFIX}/lib/rabbitmq
mkdir -p ${RABBITMQ_HOME}

# Install man pages
cp -anv src/share ${PREFIX}
rm -r src/share

# Add custom wrapper to sources
cp -n rabbitmq-script-wrapper src/sbin/rabbitmq-script-wrapper
chmod 755 src/sbin/rabbitmq-script-wrapper

# Install rabbitmq
cd src
cp -anv * ${RABBITMQ_HOME}

# Render a few files
cp_envsubst sbin/rabbitmq-script-wrapper ${RABBITMQ_HOME}/sbin
cp_envsubst sbin/rabbitmq-defaults ${RABBITMQ_HOME}/sbin

# Create links to included commands
for app in ${PREFIX}/bin/rabbitmq{ctl,-defaults,-diagnostics,-enc,-plugins,-queues,-script-wrapper,-server,-upgrade}; do
	ln -s ../lib/rabbitmq/sbin/rabbitmq-script-wrapper $app
done

# Make empty dirs
for dir in ${PREFIX}/{etc,var{/lib,/log}}/rabbitmq; do
	mkdir -p $dir
	touch $dir/.mkdir
done
