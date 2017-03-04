<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="low_coverage" select="70"/>
  <xsl:param name="ok_coverage" select="20"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>
      </head>
      <body>
        <h1>This is the coverage report</h1>
        <h2> Assembly coverage</h2>
        <p>
          <a href="coverage.coverage">Download Visual Studio Covergage File</a>
        </p>
        <table class="table">
          <tr>
            <th>Assembly</th>
            <th class="text-right">Blocks not covered</th>
            <th class="text-right">% blocks not covered</th>
          </tr>
          <xsl:for-each select="//Module">
            <xsl:sort select="ModuleName"/>
            <xsl:variable name="Module" select="translate(ModuleName,'.','_')"/>
            <tr>
              <td>
                <a data-toggle="collapse" aria-expanded="false">
                  <xsl:attribute name="href">
                    #<xsl:value-of select="$Module"/>
                  </xsl:attribute>
                  <xsl:attribute name="aria-controls">
                    <xsl:value-of select="$Module"/>
                  </xsl:attribute>
                  <xsl:value-of select="ModuleName"/>
                </a>
              </td>
              <td style="text-align:right">
                <xsl:value-of select="BlocksNotCovered"/>
              </td>
              <td class="text-right">
                <xsl:variable name="pct" select="(BlocksNotCovered div (BlocksNotCovered + BlocksCovered))*100"/>
                <xsl:attribute name="style">
                  <xsl:choose>
                    <xsl:when test="number($pct &gt;= $low_coverage)">background-color:red;</xsl:when>
                    <xsl:when test="number($pct &gt;= $ok_coverage)">background-color:yellow;</xsl:when>
                    <xsl:otherwise>background-color:green;</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="format-number($pct,0.00)"/>
              </td>
            </tr>
            <tr class="collapse">
              <xsl:attribute name="id">
                <xsl:value-of select="$Module"/>
              </xsl:attribute>
              <td colspan="3">
                <table class="table">
                  <tr>
                    <th>Class</th>
                    <th class="text-right">Blocks not covered</th>
                    <th class="text-right">% blocks not covered</th>
                  </tr>
                  <xsl:for-each select="NamespaceTable">
                  <xsl:sort select="NamespaceName"/>
                  <xsl:for-each select="Class">
                    <tr>
                      <td>
                        <xsl:value-of select="../NamespaceName"/>.<xsl:value-of select="ClassName"/>
                      </td>
                      <td style="text-align:right">
                        <xsl:value-of select="BlocksNotCovered"/>
                      </td>
                      <td>
                        <xsl:variable name="pct3" select="(BlocksNotCovered div (BlocksNotCovered + BlocksCovered))*100"/>
                        <xsl:attribute name="style">
                          text-align:right;
                          <xsl:choose>
                            <xsl:when test="number($pct3 &gt;= $low_coverage)">background-color:red;</xsl:when>
                            <xsl:when test="number($pct3 &gt;= $ok_coverage)">background-color:yellow;</xsl:when>
                            <xsl:otherwise>background-color:green;</xsl:otherwise>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$pct3"/>
                      </td>
                    </tr>
                  </xsl:for-each>
                </xsl:for-each>
                </table>
              </td>
            </tr>
          </xsl:for-each>
        </table>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>