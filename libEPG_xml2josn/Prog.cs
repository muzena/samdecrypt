using System;
namespace libEPG_xml2josn
{
    public class Prog
    {
        public string title
        {
            get;
            set;
        }
        public string description
        {
            get;
            set;
        }
        public int time
        {
            get;
            set;
        }
        public uint eventId
        {
            get;
            set;
        }
        public Prog(string title, string description, int time, uint eventId)
        {
            this.title = title;
            this.description = description;
            this.time = time;

            this.eventId = eventId;

        }
    }
}
