#!/bin/sh

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"

while [ -h "$SCRIPT" ] ; do
  ls=`ls -ld "$SCRIPT"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    SCRIPT="$link"
  else
    SCRIPT=`dirname "$SCRIPT"`/"$link"
  fi
done

if [ ! -d "${APP_DIR}" ]; then
  APP_DIR=`dirname "$SCRIPT"`/..
  APP_DIR=`cd "${APP_DIR}"; pwd`
fi

executable="./modules/openapi-generator-cli/target/openapi-generator-cli.jar"
outdir="samples/client/petstore/csharp-refactor/OpenAPIClientCore"

if [ ! -f "$executable" ]
then
  mvn -B clean package
fi

# if you've executed sbt assembly previously it will use that instead.
export JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=256M -Xmx1024M -DloggerPath=conf/log4j.properties"
ags="generate -t modules/openapi-generator/src/main/resources/csharp-refactor/ -i modules/openapi-generator/src/test/resources/2_0/petstore-with-fake-endpoints-models-for-testing.yaml -g csharp-refactor -o ${outdir} --additional-properties packageGuid={321C8C3F-0156-40C1-AE42-D59761FB9B6C},useCompareNetObjects=true,targetFramework=netcoreapp2.0 $@"

java $JAVA_OPTS -jar $executable $ags

# restore csproj file
echo "restore csproject file: CI/samples/client/petstore/csharp-refactor/OpenAPIClientCore/src/Org.OpenAPITools.Test/Org.OpenAPITools.Test.csproj"
cp ./CI/samples.ci/client/petstore/csharp-refactor/OpenAPIClientCore/src/Org.OpenAPITools.Test/Org.OpenAPITools.Test.csproj ./samples/client/petstore/csharp-refactor/OpenAPIClientCore/src/Org.OpenAPITools.Test/

