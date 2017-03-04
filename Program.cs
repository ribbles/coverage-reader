using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Xml;
using Microsoft.VisualStudio.Coverage.Analysis;

namespace CoverageReader
{
    class Program
    {
        static int Main(string[] args)
        {
            try
            {
                if (args.Length != 5)
                {
                    Console.Error.WriteLine("Usage: CoverageReader <input coverage> <bin folder> <filter> <stylesheet> <output xml>");
                    return -1;
                }
                string inputFile = args[0];
                string binFolder = args[1];
                string mask = args[2];
                string xsl = args[3];
                string outputFile = args[4];

                Console.WriteLine($"Converting from '{inputFile}' to '{outputFile}'");
                Console.WriteLine($"   using bin folder: '{binFolder}'");
                Console.WriteLine($"   stylesheet:       '{xsl}'");
                Console.WriteLine($"   filter:           '{mask}'");
                Console.WriteLine();

                using (CoverageInfo info = CoverageInfo.CreateFromFile(inputFile, new[] { binFolder }, new[] { binFolder }))
                {
                    CoverageDS data = info.BuildDataSet();

                    using (var w = new XmlTextWriter(outputFile, Encoding.UTF8))
                    {
                        w.WriteProcessingInstruction("xml-stylesheet", "type=\"text/xsl\" href=\"" + xsl + "\"");
                        data.WriteXml(w);
                    }
                    Console.WriteLine("File written.");
                    Console.WriteLine($"Analysing {inputFile}...");

                    var classesDataTable = data.Tables.Cast<DataTable>().First(dt => dt.TableName == "Class");
                    var classes = DataTableToDict(classesDataTable);
                    var coverage = CalculateCoverage(classes, mask);
                    Console.WriteLine("Unit test coverage:");
                    Console.WriteLine("   {0:0.00}% blocks", coverage.Item1);
                    Console.WriteLine("   {0:0.00}% lines", coverage.Item2);
                    if (System.Diagnostics.Debugger.IsAttached)
                    {
                        Console.WriteLine("Press any key to exit.");
                        Console.ReadLine();
                    }
                    return 0;
                }
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
                return 1;
            }
        }

        private static Tuple<decimal,decimal> CalculateCoverage(List<Dictionary<string, object>> classes, string filter)
        {
            var totalBlocksCovered = 0;
            var totalBlocksNotCovered = 0;
            var totalLinesCovered = 0;
            var totalLinesNotCovered = 0;
            foreach (var c in classes)
            {
                var classKeyName = Convert.ToString(c["ClassKeyName"]);

                if (classKeyName.Contains("unittest") || !classKeyName.Contains(filter)) continue;
                //var className = c["ClassName"];
                //var namespaceKeyName = c["NamespaceKeyName"];
                var linesCovered = Convert.ToInt32(c["LinesCovered"]);
                var linesNotCovered = Convert.ToInt32(c["LinesNotCovered"]);
                var linesPartiallyCovered = Convert.ToInt32(c["LinesPartiallyCovered"]);
                var blocksCovered = Convert.ToInt32(c["BlocksCovered"]);
                var blocksNotCovered = Convert.ToInt32(c["BlocksNotCovered"]);

                totalBlocksCovered += blocksCovered;
                totalBlocksNotCovered += blocksNotCovered;
                totalLinesCovered += (linesCovered + (linesPartiallyCovered / 2));
                totalLinesNotCovered += (linesNotCovered + (linesPartiallyCovered / 2));
                //Console.WriteLine("{0} {1} {2}", classKeyName, blocksCovered, blocksNotCovered);
            }
            var totalBlocks = totalBlocksNotCovered + totalBlocksCovered;
            if (totalBlocks == 0) totalBlocks = 1;
            var totalLines = totalLinesCovered + totalLinesNotCovered;
            if (totalLines == 0) totalLines = 1;

            return new Tuple<decimal, decimal>(
                (decimal)(100 * totalBlocksCovered) / (decimal)totalBlocks,
                (decimal)(100 * totalLinesCovered) / (decimal)totalLines
                );
        }

        static List<Dictionary<string, object>> DataTableToDict(DataTable dt)
        {
            List<Dictionary<string, object>> rows = new List<Dictionary<string, object>>();
            Dictionary<string, object> row;
            foreach (DataRow dr in dt.Rows)
            {
                row = new Dictionary<string, object>();
                foreach (DataColumn col in dt.Columns)
                    row.Add(col.ColumnName, dr[col]);
                rows.Add(row);
            }
            return rows;
        }
    }
}
