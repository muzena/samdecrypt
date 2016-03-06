using System;
using System.Collections.Generic;
namespace libEPG_xml2josn
{
    public class Channel
    {
        public string Name
        {
            get;
            set;
        }
        public List<Prog> Programs
        {
            get;
            set;
        }
        public Channel(string name)
        {
            this.Name = name;
            this.Programs = new List<Prog>();
        }
    }
}
