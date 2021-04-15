<?xml version="1.0" encoding="UTF-8"?>
<!--
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="SwfVersion"/>
    <xsl:param name="PlayerVersion"/>
    <xsl:param name="Locale"/>
    <xsl:param name="StripSwf"/>
    <xsl:param name="FlashBuilderSupport"/>

    <xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

    <!-- Replace the placeholders -->
    <xsl:template match="target-player">
        <xsl:copy><xsl:value-of select="$PlayerVersion"/></xsl:copy>
    </xsl:template>

    <!-- Replace the placeholders -->
    <xsl:template match="swf-version">
        <xsl:copy><xsl:value-of select="$SwfVersion"/></xsl:copy>
    </xsl:template>

    <!-- Replace the placeholders -->
    <xsl:template match="locale-element">
        <xsl:copy><xsl:value-of select="$Locale"/></xsl:copy>
    </xsl:template>

    <!-- Filter out the references to the playerglobal, if StripSwf is not set to 'false' -->
    <xsl:template match="external-library-path">
        <xsl:copy>
            <xsl:if test="$StripSwf = 'false'">
                <xsl:for-each select="text() | path-element">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <!-- Filter out the references to the playerglobal, if StripSwf is not set to 'false' -->
    <xsl:template match="library-path">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="$StripSwf = 'true'">
                    <xsl:if test="$FlashBuilderSupport = 'true'">
                        <path-element>libs/KeepsFBFromHanging.swc</path-element>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="* | text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <!-- The names of the Maven typedefs differ from the Ant ones, so we have to do some cleaning up here -->
    <xsl:template match="path-element">
        <xsl:choose>
            <!-- For some reason the name of the Ant lib differs from the naming pattern of the rest -->
            <xsl:when test="text() = 'libs/jQuery.swc'">
                <xsl:copy>libs/JQuery.swc</xsl:copy>
            </xsl:when>
            <!-- For some reason the name of the Ant lib differs from the naming pattern of the rest -->
            <xsl:when test="text() = 'js/libs/jQueryJS.swc'">
                <xsl:copy>js/libs/JQueryJS.swc</xsl:copy>
            </xsl:when>
            <!-- For some reason the ace typedef entry has a version number -->
            <xsl:when test="text() = '../js/libs/ace-1.2.3.swc'">
                <xsl:copy>../js/libs/royale-typedefs-ace.swc</xsl:copy>
            </xsl:when>
            <!-- The Maven artifacts of the typedefs have significantly different names -->
            <xsl:when test="starts-with(text(), '../js/libs/')">
                <xsl:variable name="cleaned-typedef-element">
                    <xsl:call-template name="cleanTypedefPathElement">
                        <xsl:with-param name="input" select="text()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:copy>../js/libs/royale-typedefs-<xsl:value-of select="$cleaned-typedef-element"/>.swc</xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="cleanTypedefPathElement">
        <xsl:param name="input"/>
        <xsl:variable name="trimmedInput" select="substring-before(substring-after($input, '../js/libs/'),'.swc')"/>
        <xsl:value-of select="translate($trimmedInput, $uppercase, $lowercase)" />
    </xsl:template>

</xsl:stylesheet>