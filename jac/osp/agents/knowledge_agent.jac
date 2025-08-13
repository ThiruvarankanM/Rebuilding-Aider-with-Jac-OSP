# knowledge_agent.jac
# Agent responsible for knowledge gathering and retrieval

agent KnowledgeAgent {
    has knowledge_base: list[dict];

    can add_knowledge(topic: str, content: str) {
        knowledge_base.append({"topic": topic, "content": content});
        print("Knowledge added: " + topic);
    }

    can get_knowledge(topic: str) -> list[dict] {
        return [k for k in knowledge_base if k.topic == topic];
    }
}
