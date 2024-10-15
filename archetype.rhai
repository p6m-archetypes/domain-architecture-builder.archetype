let context = #{};
context.services = #{};

if switch_enabled("debug-answers") {
    display("Answers:");
    display(as_yaml(ANSWERS));
}

context += render(Archetype("org-prompts"), ANSWERS);

context += prompt("Author:", "author_full", #{
    help: "Author and Email",
});

context += set("organization-name", render("{{ org-name }}-{{ solution-name }}", context), #{
    cases: [
        CasedIdentityCasedValue(PROGRAMMING_CASES),
        FixedKeyCasedValue("organization-title", TitleCase),
        FixedKeyCasedValue("OrganizationTitle", TitleCase),
    ],
});

context += prompt("Domain Gateway Name:", "project-prefix", #{
    placeholder: "Commerce",
    help: "Domain Gateway Name",
});

let services = prompt("Services:", #{
  type: List,
  help: "Micro Services",
  answer_key: "services",
});

for service in services {
    let archetype = Archetype("service");
    let service_context = #{
      "org-name": context["org-name"],
      "solution-name": context["solution-name"],
      "project-prefix": service,
      "project-suffix": "Service",
      "platform-version": "1.0.0-SNAPSHOT",
      "persistence": "CockroachDb",
    };
    let results = archetype.render(service_context);
    context.services[service] = results;
}

if switch_enabled("debug-context") {
    display("Context:");
    display(as_yaml(context));
}

render(Archetype("domain-gateway"), context + #{
    "platform-version": "1.0.0-SNAPSHOT",
});

context