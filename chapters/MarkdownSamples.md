# Markdown Sample Code

## C++ - Execution Graph Node

```{.cpp .numberLines}
class LogicNode
{
public:
    EG_DEFINE_TYPES();

    using InputSockets  = std::vector<LogicSocketInputBase*>;
    using OutputSockets = std::vector<LogicSocketOutputBase*>;

public:
    //! The basic constructor of a node.
    LogicNode(NodeId id = nodeIdInvalid)
        : m_id(id)
    {}

    LogicNode(const LogicNode&) = default;
    LogicNode(LogicNode&&)      = default;

    virtual ~LogicNode() = default;

    //! The init function.
    virtual void init() = 0;

    //! The reset function.
    virtual void reset() = 0;

    //! The main compute function of this execution node.
    virtual void compute() = 0;

public:
    NodeId id() const { return m_id; }
    void setId(NodeId id) { m_id = id; }

protected:
    //! Registers input sockets for this node.
    template<typename... Sockets>
    void registerInputs(std::tuple<Sockets...>& sockets)
    {
        m_inputs = tupleUtil::toPointers<
            [](auto*... p) { return InputSockets{p...}; }>(sockets);
    }

    //! Registers output sockets for this node.
    template<typename... Sockets>
    void registerOutputs(std::tuple<Sockets...>& sockets)
    {
        m_outputs = tupleUtil::toPointers<
            [](auto*... p) { return OutputSockets{p...}; }>(sockets);
    }

public:
    //! Get the list of input sockets.
    const InputSockets& getInputs() const { return m_inputs; }
    InputSockets& getInputs() { return m_inputs; }

    //! Get the list of output sockets.
    const OutputSockets& getOutputs() const { return m_outputs; }
    OutputSockets& getOutputs() { return m_outputs; }

    //! Get the input socket at index `index`.
    const LogicSocketInputBase* input(SocketIndex index) const
    {
        EG_THROW_IF(index >= m_inputs.size(), "Wrong index");
        return m_inputs[index];
    }

    //! Get the input socket at index `index`.
    LogicSocketInputBase* input(SocketIndex index)
    {
        EG_THROW_IF(index >= m_inputs.size(), "Wrong index");
        return m_inputs[index];
    }

    //! Get the output socket at index `index`.
    const LogicSocketOutputBase* output(SocketIndex index) const
    {
        EG_THROW_IF(index >= m_outputs.size(), "Wrong index");
        return m_outputs[index];
    }

    //! Get the output socket at index `index`.
    LogicSocketOutputBase* output(SocketIndex index)
    {
        EG_THROW_IF(index >= m_outputs.size(), "Wrong index");
        return m_outputs[index];
    }

protected:
    NodeId m_id;              //!< The id of the node.
    InputSockets m_inputs;    //!< The input sockets.
    OutputSockets m_outputs;  //!< The output sockets.
};
```

Some inline code `int a; a += "asd"`