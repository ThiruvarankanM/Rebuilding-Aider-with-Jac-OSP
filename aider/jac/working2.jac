import from mtllm.llms { Gemini }

glob llm = Gemini(model_name="gemini-1.5-flash", verbose=False);

def give_final_answer(question: str, correct: str) -> str by llm();

walker QuizGame {
    has score: int = 0;
    has attempt_count: int = 0;
    has question_num: int = 1;
    can start_quiz with `root entry;
    can answer_question with question_node entry;
}

node question_node {
    has question: str;
    has options: list[str];
    has correct: str;
    has hint: str;
}

with entry:__main__ {
    print("🎯 Welcome to the Sri Lanka Quiz Game!");
    print("=" * 40);

    q1 = root ++> question_node("What is the capital of Sri Lanka?",
        ["a) Colombo", "b) Kandy", "c) Jaffna", "d) Galle"], "a",
        "It's in the Western Province.");
        
    q2 = q1 ++> question_node("Which year did Sri Lanka gain independence?",
        ["a) 1956", "b) 1948", "c) 1972", "d) 1931"], "b",
        "It happened shortly after World War II.");

    q3 = q2 ++> question_node("What is the currency of Sri Lanka?",
        ["a) Rupee", "b) Ringgit", "c) Taka", "d) Baht"], "a",
        "It's also the currency of India, but with 'Sri Lankan' in front.");

    root spawn QuizGame();
}

##

impl QuizGame.start_quiz {
    visit [-->];
}

impl QuizGame.answer_question {
    print(f"Question {self.question_num}:");
    print(here.question);
    print();
    for opt in here.options {
        print(opt);
    }

    self.attempt_count = 0;

    while self.attempt_count < 2 {
        user_answer = input("\nYour answer (a/b/c/d): ");

        if user_answer.lower() == here.correct.lower() {
            print("✅ Correct!\n");
            self.score += 1;
            break;
        } else {
            self.attempt_count += 1;

            if self.attempt_count == 1 {
                print("❌ Incorrect.");
                print(f"💡 Hint: {here.hint}");
            } else {
                print("❌ Incorrect again.");
                try {
                    ai_output = give_final_answer(here.question, here.correct);
                    print(f"✅ Correct answer: {ai_output}");
                } except Exception as e {
                    print(f"✅ Correct answer: {here.correct}");
                }
            }
        }
    }

    self.question_num += 1;

    next_q = [-->];
    if next_q {
        visit next_q;
    } else {
        print("\n🎉 Quiz Complete! Your final score: " + str(self.score) + "/3");

        if self.score == 3 {
            print("🌟 Perfect score! Excellent knowledge of Sri Lanka!");
        } elif self.score == 2 {
            print("👍 Good job! You know Sri Lanka well!");
        } elif self.score == 1 {
            print("📚 Not bad! Keep learning about Sri Lanka!");
        } else {
            print("🔄 Time to brush up on Sri Lanka facts!");
        }
    }
}