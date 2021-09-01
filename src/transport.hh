#ifdef __TRANSPORT_HH__
#define __TRANSPORT_HH__

#include <exception>
#include <functional>
#include <pEp/transport.h>

namespace pEp {
    class Transport {
        const PEP_transport_id id;
        
        public:
            struct TransportError : std::runtime_error {
                const PEP_transport_status_code tsc;

                TransportError(PEP_transport_status_code tsc) :
                    std::runtime_error("transport error"), tsc(tsc) { }
            };

            struct ConfigError : std::logic_error {
                ConfigError() : std::logic_error("config error") { }
            };

            class Config {
                public:
                    Config() { }
                    virtual Config(const Config& second) { }
                    virtual ~Config() { }
            };

            Transport(PEP_transport_id id) : id(id) { }
            Transport(const Transport&) = delete;
            Transport& operator=(const Transport&) = delete;

            virtual ~Transport() { }

            PEP_transport_id get_id() { return id; }

            virtual void configure(const Config& config);
            virtual void startup(callback_execution cbe = PEP_cbe_polling);
            virtual void shutdown();

            virtual void sendto(pEp::Message& msg);
            virtual Message recvnext();

            virtual void
                signal_statuschange(std::function(void(PEP_transport_status_code)));

            virtual void
                signal_sendto_result(std::function(void(std::string,
                                std::string, PEP_transport_status_code)));

            virtual void
                signal_incoming_message(std::function(void(PEP_transport_status_code)));

            virtual bool shortmsg_supported();
            virtual bool longmsg_supported();
            virtual bool longmsg_formatted_supported();
            virtual PEP_text_format native_text_format();
    };
};

#endif // __TRANSPORT_HH__
