import org.yaml.snakeyaml.Yaml
import groovy.io.FileType

println 'start '

Yaml parser = new Yaml()

def sla_folder = new File( '/usr/local/structurizr/sla');


def api_specification = workspace.model.addSoftwareSystem( "API Specification", "AI specification and SLA")
def spec_container = api_specification.addContainer('API Specification container')

def elements_map = [:];
def createSLAElement( i, protocol ,id){
    def sla = workspace.model.addCustomElement( "SLA for " + i, /type:interface;api:${i};protocol:${protocol};id:${id}/, "");
    sla.addTags( "export", "generated");
    return sla;
}

 workspace.model.getElements().each{
    def variable_name = it.properties["structurizr.dsl.identifier"]
    if( variable_name )
        elements_map[(variable_name)] = it;
 }

sla_folder.eachFileRecurse {
    def sla_manifest = parser.load(it.text)
    sla_manifest.rest.each{
        key,paths->{
            def interface_o = elements_map[key]
            if( !interface_o) {
                println 'Interface not found '  + key;
                return;
            }
            def sla = createSLAElement(key, "rest",interface_o.id);

            paths.each{
                path,methods->{
                    methods.each{
                        m,v->sla.addProperty( /${m} ${path}/, /rps:${v.rps};latency:${v.latency};error_rate:${v.error_rate}/ )
                    }
                }
            }
            println sla.properties
        }
    }

     sla_manifest.soap.each{
        key,value->{
            def interface_o = elements_map[key]
            if( !interface_o) {
                println 'Interface not found '  + key;
                return;
            }
            def sla = createSLAElement(key, "soap",interface_o.id);         
            
            value.each{
                operation, v ->{ sla.addProperty( operation, /rps:${v.rps};latency:${v.latency};error_rate:${v.error_rate}/  )}
            }
            
            println sla.properties
        }
    }
}





