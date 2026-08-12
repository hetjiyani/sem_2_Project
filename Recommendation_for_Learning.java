

public class Recommendation_for_Learning {
    public void RELearning(String data){
        StringBuilder prompt=new StringBuilder(data);
        prompt.append("""

Analyze the user's profile.

Compare the user's skills and proficiency levels with the required skills of every registered hackathon.

For each hackathon:

1. Calculate how well the user's skills match.
2. Mention matching skills.
3. Mention missing skills.
4. Recommend what the user should learn.
5. Recommend learning order.
6. Suggest useful technologies.
7. Suggest whether the user is ready.or they can join a team who have that required skills
8. Give a readiness percentage.
9. Keep the answer clear and professional.

""");

        ai a=new ai(prompt.toString());
    }
}
