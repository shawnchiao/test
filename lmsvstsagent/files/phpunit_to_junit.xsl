<?xml version="1.0" encoding="UTF-8"?>
<!--

PHPUnit does not output valid junit files. This XSLT file transforms the
output it does have to be valid.

Found here on a jetbrains Teamcity issue (they added an exception to their
junit parser since PHPUnit shows no inclination to change):
https://youtrack.jetbrains.com/issue/TW-17249#comment=27-231993

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"   xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">
    <xsl:output method="xml"/>
    <xsl:template match="/">
        <xsl:for-each select="//testsuite[@file]">
            <xsl:variable name="filename" select="@name" />
            <exsl:document href="JTEST-{$filename}.xml" method="xml">
                <xsl:copy-of select="." />
            </exsl:document>
            <xsl:for-each select="current()/testsuite">
                <xsl:variable name="subname" select="@name" />
                <xsl:variable name="subnameclean" select="translate($subname,'::','')" />
                <exsl:document href="JTEST-{$subnameclean}-{$filename}.xml" method="xml">
                    <xsl:copy-of select="." />
                </exsl:document>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>